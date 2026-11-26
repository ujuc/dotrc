//! dotrc installer: `scripts/install.sh` builds and runs this binary.
//!
//! Groups run in a fixed order after a link preflight that aborts the whole run
//! before any step when a managed link destination conflicts. Independent steps
//! keep going after a failure; the summary lists every failed step with the
//! command to rerun, and the exit code is 1 when any failed.

mod install;
mod links;
mod runner;

use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

use links::{Groups, Layout};
use runner::Runner;

const USAGE: &str = "\
Usage: install.sh [--cli] [--apps] [--fonts] [--agents] [--all]

Options:
    --cli       Install command-line tools and configuration
    --apps      Install applications
    --fonts     Install fonts
    --agents    Install agent configuration
    --all       Install all groups
    -h, --help  Show this help";

enum Parsed {
    Run(Groups),
    Help,
    Unknown(String),
}

fn parse_args(args: impl IntoIterator<Item = String>) -> Parsed {
    let mut groups = Groups::default();
    let mut any = false;
    for arg in args {
        any = true;
        match arg.as_str() {
            "--cli" => groups.cli = true,
            "--apps" => groups.apps = true,
            "--fonts" => groups.fonts = true,
            "--agents" => groups.agents = true,
            "--all" => {
                groups = Groups {
                    cli: true,
                    apps: true,
                    fonts: true,
                    agents: true,
                }
            }
            "-h" | "--help" => return Parsed::Help,
            _ => return Parsed::Unknown(arg),
        }
    }
    if any {
        Parsed::Run(groups)
    } else {
        Parsed::Help
    }
}

/// The repository root: `DOTRCDIR`, which `install.sh` sets to its own checkout,
/// else two levels above this crate when the binary is run directly.
fn dotrc_root() -> PathBuf {
    non_empty_env("DOTRCDIR").unwrap_or_else(|| {
        let root = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../..");
        root.canonicalize().unwrap_or(root)
    })
}

fn non_empty_env(name: &str) -> Option<PathBuf> {
    env::var_os(name)
        .filter(|value| !value.is_empty())
        .map(PathBuf::from)
}

fn main() -> ExitCode {
    let groups = match parse_args(env::args().skip(1)) {
        Parsed::Run(groups) => groups,
        Parsed::Help => {
            println!("{USAGE}");
            return ExitCode::SUCCESS;
        }
        Parsed::Unknown(arg) => {
            eprintln!("Unknown option: {arg}\n{USAGE}");
            return ExitCode::from(2);
        }
    };
    let Some(home) = non_empty_env("HOME") else {
        eprintln!("HOME is not set");
        return ExitCode::FAILURE;
    };
    let layout = Layout {
        dotrc: dotrc_root(),
        xdg_config: non_empty_env("XDG_CONFIG_HOME").unwrap_or_else(|| home.join(".config")),
        home,
    };

    let problems = layout.preflight(groups);
    if !problems.is_empty() {
        for problem in problems {
            eprintln!("{problem}");
        }
        eprintln!("Link preflight failed; no installation steps were run.");
        return ExitCode::FAILURE;
    }

    let mut runner = Runner::new();
    // mise, Claude and Amp install into ~/.local/bin, which zshrc adds only after it is linked.
    runner.prepend_path(layout.home.join(".local/bin"));
    if (groups.cli || groups.apps || groups.fonts) && install::ensure_homebrew(&mut runner).is_err()
    {
        runner.summary();
        return ExitCode::FAILURE;
    }
    if groups.cli {
        install::install_cli(&mut runner, &layout);
    }
    if groups.apps {
        install::install_apps(&mut runner, &layout);
    }
    if groups.fonts {
        install::install_fonts(&mut runner);
    }
    if groups.agents {
        install::install_agents(&mut runner, &layout);
    }
    if runner.summary() == 0 {
        ExitCode::SUCCESS
    } else {
        ExitCode::FAILURE
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn parse(args: &[&str]) -> Parsed {
        parse_args(args.iter().map(|arg| (*arg).to_owned()))
    }

    #[test]
    fn parses_groups_help_and_unknown_options() {
        assert!(matches!(parse(&[]), Parsed::Help));
        assert!(matches!(parse(&["--cli", "--help"]), Parsed::Help));
        assert!(matches!(parse(&["--nope"]), Parsed::Unknown(arg) if arg == "--nope"));
        let Parsed::Run(groups) = parse(&["--cli", "--agents"]) else {
            panic!()
        };
        assert_eq!(
            groups,
            Groups {
                cli: true,
                apps: false,
                fonts: false,
                agents: true
            }
        );
        let Parsed::Run(groups) = parse(&["--all"]) else {
            panic!()
        };
        assert_eq!(
            groups,
            Groups {
                cli: true,
                apps: true,
                fonts: true,
                agents: true
            }
        );
    }
}
