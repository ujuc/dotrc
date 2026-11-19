use anyhow::{Context, Result};
use clap::Parser;
use owo_colors::OwoColorize;
use skill_core::{Severity, validate_skill};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

#[derive(Parser)]
#[command(
    name = "validate-skill",
    about = "Validate a Claude skill directory structure and frontmatter."
)]
struct Args {
    /// Path to the skill directory
    skill_dir: PathBuf,
}

/// Claude Code names a symlinked skill folder by the link, not its target, so
/// keep the last component as given; resolve only a path with no name (`..`).
fn resolve_skill_dir(given: &Path) -> Result<PathBuf> {
    let not_found = || format!("skill directory not found: {}", given.display());
    let abs = std::path::absolute(given).with_context(not_found)?;
    if abs.file_name().is_some() && abs.is_dir() {
        return Ok(abs);
    }
    given.canonicalize().with_context(not_found)
}

fn main() -> Result<ExitCode> {
    let args = Args::parse();
    let skill_dir = resolve_skill_dir(&args.skill_dir)?;

    println!("Validating skill: {}", skill_dir.display());
    println!();

    let report = validate_skill(&skill_dir)?;

    let mut current_section: &'static str = "";
    for f in &report.findings {
        if f.section != current_section {
            if !current_section.is_empty() {
                println!();
            }
            println!("{} checks:", f.section);
            current_section = f.section;
        }
        match f.severity {
            Severity::Pass => println!("  {} {}", "✓".green(), f.message),
            Severity::Fail => println!("  {} {}", "✗".red(), f.message),
            Severity::Warn => println!("  {} {}", "!".yellow(), f.message),
        }
    }

    println!();
    let errors = report.errors();
    if errors == 0 {
        println!("{}", "All checks passed.".green().bold());
        Ok(ExitCode::SUCCESS)
    } else {
        println!("{}", format!("{errors} error(s) found.").red().bold());
        Ok(ExitCode::FAILURE)
    }
}

#[cfg(all(test, unix))]
mod tests {
    #[test]
    fn symlinked_skill_keeps_link_name() {
        let base = std::env::temp_dir().join(format!("validate-skill-test-{}", std::process::id()));
        let target = base.join("real-name");
        std::fs::create_dir_all(&target).unwrap();
        let link = base.join("alias-name");
        std::os::unix::fs::symlink(&target, &link).unwrap();
        let got = super::resolve_skill_dir(&link);
        std::fs::remove_dir_all(&base).unwrap();
        assert_eq!(got.unwrap().file_name().unwrap(), "alias-name");
    }
}
