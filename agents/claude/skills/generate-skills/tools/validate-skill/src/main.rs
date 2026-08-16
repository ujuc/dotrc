use anyhow::{Context, Result};
use clap::Parser;
use owo_colors::OwoColorize;
use skill_core::{Severity, validate_skill};
use std::path::PathBuf;
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

fn main() -> Result<ExitCode> {
    let args = Args::parse();
    let skill_dir = args
        .skill_dir
        .canonicalize()
        .with_context(|| format!("skill directory not found: {}", args.skill_dir.display()))?;

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
