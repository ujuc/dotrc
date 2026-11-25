//! Runs installation steps, prints them the way the old shell script did, and
//! collects failures for the final summary.

use std::env;
use std::ffi::OsString;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

pub struct Failure {
    pub group: String,
    pub label: String,
    pub status: i32,
    pub command: String,
}

/// Step runner with its own `PATH`, so installers that add a bin directory
/// (Homebrew, mise, Claude Code, waza) are visible to later steps without
/// touching this process's environment.
pub struct Runner {
    path: Vec<PathBuf>,
    pub failures: Vec<Failure>,
    pub last_status: i32,
}

impl Runner {
    pub fn new() -> Self {
        let path = env::var_os("PATH")
            .map(|value| env::split_paths(&value).collect())
            .unwrap_or_default();
        Self::with_path(path)
    }

    pub fn with_path(path: Vec<PathBuf>) -> Self {
        Self {
            path,
            failures: Vec::new(),
            last_status: 0,
        }
    }

    pub fn prepend_path(&mut self, dir: impl Into<PathBuf>) {
        let dir = dir.into();
        self.path.retain(|existing| existing != &dir);
        self.path.insert(0, dir);
    }

    fn path_value(&self) -> OsString {
        env::join_paths(&self.path).unwrap_or_default()
    }

    /// `command -v <name>`: an executable file named `name` on this runner's `PATH`.
    pub fn find(&self, name: &str) -> Option<PathBuf> {
        self.path
            .iter()
            .map(|dir| dir.join(name))
            .find(|candidate| is_executable(candidate))
    }

    pub fn has(&self, name: &str) -> bool {
        self.find(name).is_some()
    }

    pub fn command(&self, program: impl AsRef<std::ffi::OsStr>) -> Command {
        let mut command = Command::new(program);
        command.env("PATH", self.path_value());
        command
    }

    /// Runs a command quietly and reports whether it exited 0.
    pub fn succeeds(&self, program: &str, args: &[&str]) -> bool {
        self.command(program)
            .args(args)
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .is_ok_and(|status| status.success())
    }

    /// Runs a command with inherited stdio; its exit code becomes `last_status`.
    pub fn run(&mut self, group: &str, label: &str, program: &str, args: &[&str]) {
        let shown = shell_words(std::iter::once(program).chain(args.iter().copied()));
        println!("[{group}] {label}");
        println!("$ {shown}");
        let status = match self.command(program).args(args).status() {
            Ok(status) => status.code().unwrap_or(1),
            Err(error) => {
                eprintln!("{program}: {error}");
                127
            }
        };
        self.finish(group, label, status, shown);
    }

    /// `/bin/bash -o pipefail -c <script>`, for the upstream `curl … | sh` installers.
    pub fn run_shell(&mut self, group: &str, label: &str, script: &str) {
        self.run(group, label, "/bin/bash", &["-o", "pipefail", "-c", script]);
    }

    /// Runs an in-process filesystem action as a step; `shown` is its shell equivalent.
    pub fn run_native(
        &mut self,
        group: &str,
        label: &str,
        shown: String,
        action: impl FnOnce() -> std::io::Result<()>,
    ) {
        println!("[{group}] {label}");
        println!("$ {shown}");
        let status = match action() {
            Ok(()) => 0,
            Err(error) => {
                eprintln!("{error}");
                1
            }
        };
        self.finish(group, label, status, shown);
    }

    fn finish(&mut self, group: &str, label: &str, status: i32, shown: String) {
        self.last_status = status;
        if status == 0 {
            println!("[{group}] Done: {label}");
        } else {
            eprintln!("[{group}] Failed ({status}): {label}");
            self.record(group, label, status, shown);
        }
    }

    pub fn record(&mut self, group: &str, label: &str, status: i32, command: impl Into<String>) {
        self.failures.push(Failure {
            group: group.to_owned(),
            label: label.to_owned(),
            status,
            command: command.into(),
        });
    }

    /// Prints the failure list and returns the process exit code.
    pub fn summary(&self) -> i32 {
        if self.failures.is_empty() {
            return 0;
        }
        println!("\nFailures: {}", self.failures.len());
        for (index, failure) in self.failures.iter().enumerate() {
            println!(
                "{}. [{}] {} (exit {})",
                index + 1,
                failure.group,
                failure.label,
                failure.status
            );
            println!("   $ {}", failure.command);
        }
        1
    }
}

fn is_executable(path: &Path) -> bool {
    use std::os::unix::fs::PermissionsExt;
    path.metadata()
        .is_ok_and(|meta| meta.is_file() && meta.permissions().mode() & 0o111 != 0)
}

/// Quotes each word only when the shell would need it.
pub fn shell_words<'a>(words: impl IntoIterator<Item = &'a str>) -> String {
    words
        .into_iter()
        .map(shell_quote)
        .collect::<Vec<_>>()
        .join(" ")
}

pub fn shell_quote(word: &str) -> String {
    let plain = !word.is_empty()
        && word
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || "_@%+=:,./-".contains(c));
    if plain {
        word.to_owned()
    } else {
        format!("'{}'", word.replace('\'', r"'\''"))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn quotes_only_words_that_need_it() {
        assert_eq!(
            shell_words(["git", "config", "--global", "core.pager", "delta"]),
            "git config --global core.pager delta"
        );
        assert_eq!(shell_quote("delta --color-only"), "'delta --color-only'");
        assert_eq!(shell_quote("it's"), r"'it'\''s'");
        assert_eq!(shell_quote(""), "''");
    }

    #[test]
    fn summary_exit_code_follows_failures() {
        let mut runner = Runner::with_path(Vec::new());
        assert_eq!(runner.summary(), 0);
        runner.record("cli", "Configure git user.name manually", 1, "git config");
        assert_eq!(runner.summary(), 1);
    }

    #[test]
    fn missing_program_is_a_recorded_failure() {
        let mut runner = Runner::with_path(Vec::new());
        runner.run("cli", "Run nothing", "/nonexistent/program", &[]);
        assert_eq!(runner.last_status, 127);
        assert_eq!(runner.failures.len(), 1);
    }

    #[test]
    fn prepended_dirs_are_searched_first_and_not_duplicated() {
        let mut runner = Runner::with_path(vec![PathBuf::from("/usr/bin")]);
        runner.prepend_path("/opt/homebrew/bin");
        runner.prepend_path("/usr/bin");
        assert_eq!(
            runner.path,
            vec![
                PathBuf::from("/usr/bin"),
                PathBuf::from("/opt/homebrew/bin")
            ]
        );
        assert!(runner.has("sh") || !Path::new("/usr/bin/sh").exists());
    }
}
