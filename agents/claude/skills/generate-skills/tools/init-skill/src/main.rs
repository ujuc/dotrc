use anyhow::{Context, Result, bail};
use clap::Parser;
use skill_core::rules;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

const DEFAULT_PATH: &str = "agents/claude/skills";
const NAME_MAX_LEN: usize = 64;

const SKILL_TEMPLATE: &str = "---
name: {name}
description: |
  TODO: What does this skill do? (WHAT)
  TODO: When should it trigger? Include example phrases. (WHEN)
group: {group}
# Optional fields — uncomment and fill in as needed.
# when_to_use: \"Trigger phrases and example utterances separated from description\"
# model: opus                        # opus | sonnet | haiku
# effort: high                       # low | medium | high | xhigh | max
# disable-model-invocation: true     # for destructive / high-cost workflows
# argument-hint: \"[target]\"
# allowed-tools: Read Grep Glob      # or YAML list
# paths: \"src/**/*.rs\"                # glob for auto-activation scope
# shell: bash                        # bash | powershell
# context: fork                      # run in forked subagent context
# agent: Explore                     # requires context: fork
# background: false                  # requires context: fork — wait for the result
---

# TODO: Skill Title

TODO: One-line description of what this skill does.

If $ARGUMENTS is provided, treat it as the target path / name. Otherwise, ask the user.

## Step 1: TODO

TODO: Describe the first step.

---

## Step 2: TODO

TODO: Describe the second step.

---

## Validation

TODO: Describe how to verify the output.

```bash
# TODO: validation command
```
";

#[derive(Parser)]
#[command(
    name = "init-skill",
    about = "Scaffold a new Claude skill directory."
)]
struct Args {
    /// Skill name in kebab-case (e.g. my-new-skill)
    name: String,

    /// Catalog group slug (required by validate-skill; never guessed)
    #[arg(long)]
    group: String,

    /// Target parent directory
    #[arg(long, default_value = DEFAULT_PATH)]
    path: PathBuf,

    /// Create empty references/ subdirectory
    #[arg(long)]
    with_references: bool,

    /// Create empty scripts/ subdirectory
    #[arg(long)]
    with_scripts: bool,

    /// Create empty assets/ subdirectory
    #[arg(long)]
    with_assets: bool,
}

fn main() -> Result<ExitCode> {
    let args = Args::parse();

    if !rules::is_kebab_case(&args.name) {
        eprintln!("error: name must be kebab-case: '{}'", args.name);
        eprintln!("  valid:   my-skill, generate-skills, notion-setup");
        eprintln!("  invalid: MySkill, my_skill, -my-skill, my--skill");
        return Ok(ExitCode::FAILURE);
    }

    if args.name.len() > NAME_MAX_LEN {
        eprintln!(
            "error: name must be {} characters or fewer (got {})",
            NAME_MAX_LEN,
            args.name.len()
        );
        return Ok(ExitCode::FAILURE);
    }

    if rules::RESERVED_NAME_PREFIXES
        .iter()
        .any(|p| args.name.starts_with(p))
    {
        eprintln!(
            "error: name must not start with reserved prefix ({:?})",
            rules::RESERVED_NAME_PREFIXES
        );
        return Ok(ExitCode::FAILURE);
    }

    if !rules::ALLOWED_GROUPS.contains(&args.group.as_str()) {
        eprintln!(
            "error: unknown group '{}' — allowed: {}",
            args.group,
            rules::ALLOWED_GROUPS.join(", ")
        );
        return Ok(ExitCode::FAILURE);
    }

    create_skill(&args)?;
    Ok(ExitCode::SUCCESS)
}

fn create_skill(args: &Args) -> Result<()> {
    let skill_dir = args.path.join(&args.name);

    if skill_dir.exists() {
        bail!("directory already exists: {}", skill_dir.display());
    }

    fs::create_dir_all(&skill_dir)
        .with_context(|| format!("failed to create {}", skill_dir.display()))?;

    let skill_md = skill_dir.join("SKILL.md");
    let content = SKILL_TEMPLATE
        .replace("{name}", &args.name)
        .replace("{group}", &args.group);
    fs::write(&skill_md, content)
        .with_context(|| format!("failed to write {}", skill_md.display()))?;

    let mut optional_dirs: Vec<&str> = Vec::new();
    for (flag, dirname) in [
        (args.with_references, "references"),
        (args.with_scripts, "scripts"),
        (args.with_assets, "assets"),
    ] {
        if !flag {
            continue;
        }
        let sub_dir = skill_dir.join(dirname);
        fs::create_dir_all(&sub_dir)
            .with_context(|| format!("failed to create {}", sub_dir.display()))?;
        let gitkeep = sub_dir.join(".gitkeep");
        fs::write(&gitkeep, "")
            .with_context(|| format!("failed to write {}", gitkeep.display()))?;
        optional_dirs.push(dirname);
    }

    print_summary(&skill_dir, &args.name, &args.group, &optional_dirs);
    Ok(())
}

fn print_summary(skill_dir: &Path, name: &str, group: &str, optional_dirs: &[&str]) {
    println!("Created: {}", skill_dir.display());
    println!();
    println!("  {name}/");
    println!("  └── SKILL.md");
    for d in optional_dirs {
        println!("      {d}/  (empty)");
    }
    println!();
    println!("Next steps:");
    println!("  1. Edit SKILL.md — fill in TODO placeholders");
    println!("  2. Validate:");
    println!(
        "     bash agents/claude/skills/generate-skills/scripts/validate-skill {}",
        skill_dir.display()
    );
    println!("  3. Register in the catalog group map:");
    println!(
        "     bash agents/claude/skills/generate-skills/scripts/register-skill \\"
    );
    println!(
        "       agents/claude/skills/README.md --name {name} --group {group}"
    );
}
