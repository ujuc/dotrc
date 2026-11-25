//! The four install groups: cli, apps, fonts, agents.

use std::io::{self, BufRead, IsTerminal, Write};
use std::path::Path;

use crate::links::{Layout, safe_link};
use crate::runner::Runner;

/// Installs Homebrew if needed and puts it on the runner's `PATH`.
/// `Err` means later brew steps cannot run.
pub fn ensure_homebrew(runner: &mut Runner) -> Result<(), ()> {
    if !runner.has("brew") {
        runner.run_shell(
            "homebrew",
            "Install Homebrew",
            r#"/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)""#,
        );
        if runner.last_status != 0 {
            return Err(());
        }
    }
    for prefix in ["/opt/homebrew", "/usr/local"] {
        if Path::new(prefix).join("bin/brew").is_file() {
            runner.prepend_path(Path::new(prefix).join("sbin"));
            runner.prepend_path(Path::new(prefix).join("bin"));
            break;
        }
    }
    if !runner.has("brew") {
        runner.record(
            "homebrew",
            "Find brew after installation",
            1,
            "command -v brew",
        );
        return Err(());
    }
    Ok(())
}

fn install_formula(runner: &mut Runner, group: &str, name: &str) {
    if !runner.succeeds("brew", &["list", "--formula", name]) {
        runner.run(
            group,
            &format!("Install formula {name}"),
            "brew",
            &["install", name],
        );
    }
}

fn install_cask(runner: &mut Runner, group: &str, name: &str) {
    if !runner.succeeds("brew", &["list", "--cask", name]) {
        runner.run(
            group,
            &format!("Install cask {name}"),
            "brew",
            &["install", "--cask", name],
        );
    }
}

pub fn install_cli(runner: &mut Runner, layout: &Layout) {
    for cask in ["1password", "1password-cli"] {
        install_cask(runner, "cli", cask);
    }
    for formula in [
        "gh",
        "starship",
        "zimfw",
        "coreutils",
        "bat",
        "eza",
        "zoxide",
        "fzf",
        "vim",
        "git",
        "git-delta",
        "tig",
        "yq",
    ] {
        install_formula(runner, "cli", formula);
    }
    if !runner.has("mise") {
        runner.run_shell("cli", "Install mise", "curl https://mise.run | sh");
        runner.prepend_path(layout.home.join(".local/bin"));
    }
    if runner.has("mise") {
        runner.run("cli", "Install uv with mise", "mise", &["use", "-g", "uv"]);
        runner.run(
            "cli",
            "Install node with mise",
            "mise",
            &["use", "-g", "node"],
        );
    } else {
        runner.record("cli", "Find mise after installation", 1, "command -v mise");
    }
    configure_git(runner, layout);
    let authenticated = runner
        .command("gh")
        .args(["auth", "status"])
        .status()
        .is_ok_and(|status| status.success());
    if !authenticated {
        runner.run("cli", "Authenticate GitHub CLI", "gh", &["auth", "login"]);
    }
    for (source, destination) in layout.cli_links() {
        safe_link(runner, &source, &destination);
    }
}

fn configure_git(runner: &mut Runner, layout: &Layout) {
    let template = layout.dotrc.join("gitmessage");
    let template = template.to_string_lossy();
    let settings = [
        ("core.autocrlf", "input"),
        (
            "core.whitespace",
            "cr-at-eol,fix,trailing-space,-indent-with-non-tab",
        ),
        ("merge.conflictstyle", "zdiff3"),
        ("init.defaultBranch", "main"),
        ("commit.template", &template),
        ("core.pager", "delta"),
        ("interactive.diffFilter", "delta --color-only"),
        ("delta.line-numbers", "true"),
        ("delta.side-by-side", "true"),
        ("delta.navigate", "true"),
        ("delta.diff-so-fancy", "true"),
        ("delta.hyperlinks", "true"),
    ];
    for (key, value) in settings {
        runner.run(
            "cli",
            &format!("Configure git {key}"),
            "git",
            &["config", "--global", key, value],
        );
    }
    configure_git_identity(runner, "user.name", "Git user name");
    configure_git_identity(runner, "user.email", "Git user email");
    let dotrc = layout.dotrc.to_string_lossy();
    runner.run(
        "cli",
        "Configure root git hooks",
        "git",
        &["-C", &dotrc, "config", "core.hooksPath", ".githooks"],
    );
}

fn configure_git_identity(runner: &mut Runner, key: &str, prompt: &str) {
    if runner.succeeds("git", &["config", "--global", "--get", key]) {
        return;
    }
    if io::stdin().is_terminal() {
        print!("{prompt}: ");
        let _ = io::stdout().flush();
        let mut value = String::new();
        if io::stdin().lock().read_line(&mut value).is_ok() {
            let value = value.trim_end_matches(['\r', '\n']);
            if !value.is_empty() {
                runner.run(
                    "cli",
                    &format!("Configure git {key}"),
                    "git",
                    &["config", "--global", key, value],
                );
                return;
            }
        }
    }
    let command = format!("git config --global {key} '<value>'");
    eprintln!("[cli] Missing {key}; run: {command}");
    runner.record("cli", &format!("Configure git {key} manually"), 1, command);
}

pub fn install_apps(runner: &mut Runner, layout: &Layout) {
    let apple_silicon = cfg!(target_os = "macos") && std::env::consts::ARCH == "aarch64";
    if apple_silicon
        && !runner.succeeds(
            "pkgutil",
            &["--pkg-info", "com.apple.pkg.RosettaUpdateAuto"],
        )
    {
        runner.run(
            "apps",
            "Install Rosetta",
            "sudo",
            &["softwareupdate", "--install-rosetta", "--agree-to-license"],
        );
    }
    for cask in [
        "raycast",
        "zed",
        "visual-studio-code",
        "ghostty",
        "fujitsu-scansnap-home",
        "google-drive",
        "adobe-creative-cloud",
    ] {
        install_cask(runner, "apps", cask);
    }
    for (source, destination) in layout.app_links() {
        safe_link(runner, &source, &destination);
    }
}

pub fn install_fonts(runner: &mut Runner) {
    for cask in [
        "font-google-sans-code",
        "font-cascadia-code",
        "font-cascadia-code-nf",
        "font-d2coding-nerd-font",
        "font-ibm-plex-sans-kr",
        "font-ibm-plex-serif",
        "font-noto-color-emoji",
        "font-noto-emoji",
        "font-noto-sans-cjk",
        "font-noto-serif-cjk",
        "font-nanum-square",
        "font-nanum-square-neo",
        "font-nanum-square-round",
    ] {
        install_cask(runner, "fonts", cask);
    }
}

const MARKETPLACES: [(&str, &str); 5] = [
    (
        "anthropics/claude-plugins-official",
        "claude-plugins-official",
    ),
    ("dietrichgebert/ponytail", "ponytail"),
    ("ayghri/i-have-adhd", "i-have-adhd"),
    ("jarrodwatts/claude-hud", "claude-hud"),
    ("typesafe-ai/skills", "typesafe-ai"),
];

const PLUGINS: [&str; 6] = [
    "superpowers@claude-plugins-official",
    "remember@claude-plugins-official",
    "ponytail@ponytail",
    "i-have-adhd@i-have-adhd",
    "claude-hud@claude-hud",
    "typesafe@typesafe-ai",
];

const OMP_SETTINGS: [(&str, &str); 2] = [
    ("enabledProviders", r#"["claude","claude-plugins"]"#),
    (
        "skills.customDirectories",
        r#"["~/.claude/skills/ujuc/skills","~/.claude/skills/egm/skills","~/.claude/skills/skill-diet/skills"]"#,
    ),
];

pub fn install_agents(runner: &mut Runner, layout: &Layout) {
    if !runner.has("claude") {
        runner.run_shell(
            "agents",
            "Install Claude Code",
            "curl -fsSL https://claude.ai/install.sh | bash",
        );
        runner.prepend_path(layout.home.join(".local/bin"));
    }
    if !runner.has("waza") {
        runner.run_shell(
            "agents",
            "Install waza",
            "curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash",
        );
        runner.prepend_path(layout.home.join("bin"));
    }
    if runner.has("claude") {
        match claude_json(runner, &["plugin", "marketplace", "list", "--json"]) {
            Ok(json) => {
                for (source, name) in MARKETPLACES {
                    if !json_has_string_field(&json, "name", name) {
                        runner.run(
                            "agents",
                            &format!("Add marketplace {source}"),
                            "claude",
                            &["plugin", "marketplace", "add", source],
                        );
                    }
                }
            }
            Err(status) => runner.record(
                "agents",
                "List plugin marketplaces",
                status,
                "claude plugin marketplace list --json",
            ),
        }
        match claude_json(runner, &["plugin", "list", "--json"]) {
            Ok(json) => {
                for plugin in PLUGINS {
                    if !json_has_string_field(&json, "id", plugin) {
                        runner.run(
                            "agents",
                            &format!("Install plugin {plugin}"),
                            "claude",
                            &["plugin", "install", plugin],
                        );
                    }
                }
            }
            Err(status) => runner.record(
                "agents",
                "List plugins",
                status,
                "claude plugin list --json",
            ),
        }
    } else {
        runner.record(
            "agents",
            "Find Claude after installation",
            1,
            "command -v claude",
        );
    }
    layout.migrate_legacy_agent_dirs(runner);
    for (source, destination) in layout.agent_links() {
        safe_link(runner, &source, &destination);
    }
    // omp reads Claude skills itself once the user-level providers are on;
    // the nested personal roots need explicit directories.
    if runner.has("omp") {
        for (key, value) in OMP_SETTINGS {
            runner.run(
                "agents",
                &format!("Set omp {key}"),
                "omp",
                &["config", "set", key, value],
            );
        }
    }
    // settings.json is untracked on purpose; the README keeps the copy to paste.
    let settings = layout.agents().join("claude/settings.json");
    if !settings.is_file() {
        runner.record(
            "agents",
            "Write ~/.claude/settings.json from README (Claude > settings.json)",
            1,
            format!("${{EDITOR:-vi}} {}", settings.display()),
        );
    }
}

/// Runs `claude <args>`, echoes its combined output, and returns stdout on success.
fn claude_json(runner: &Runner, args: &[&str]) -> Result<String, i32> {
    let output = runner
        .command("claude")
        .args(args)
        .output()
        .map_err(|_| 127)?;
    let stdout = String::from_utf8_lossy(&output.stdout).into_owned();
    print!("{stdout}");
    eprint!("{}", String::from_utf8_lossy(&output.stderr));
    if output.status.success() {
        Ok(stdout)
    } else {
        Err(output.status.code().unwrap_or(1))
    }
}

/// True when `json` holds `"field": "value"` anywhere, whitespace around `:` allowed.
pub fn json_has_string_field(json: &str, field: &str, value: &str) -> bool {
    let key = format!("\"{field}\"");
    let wanted = format!("\"{value}\"");
    json.match_indices(&key).any(|(index, _)| {
        let rest = json[index + key.len()..].trim_start();
        rest.strip_prefix(':')
            .is_some_and(|rest| rest.trim_start().starts_with(&wanted))
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn finds_exact_string_fields() {
        let json = r#"[{"name": "ponytail"}, {"id":"claude-hud@claude-hud","name" :"x"}]"#;
        assert!(json_has_string_field(json, "name", "ponytail"));
        assert!(json_has_string_field(json, "id", "claude-hud@claude-hud"));
        assert!(json_has_string_field(json, "name", "x"));
        assert!(!json_has_string_field(json, "name", "pony"));
        assert!(!json_has_string_field(json, "id", "ponytail"));
        assert!(!json_has_string_field("", "id", "x"));
    }
}
