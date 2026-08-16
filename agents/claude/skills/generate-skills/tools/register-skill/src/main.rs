use anyhow::{Context, Result, anyhow};
use clap::Parser;
use skill_core::rules;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

#[derive(Parser)]
#[command(
    name = "register-skill",
    about = "Idempotently register a skill in the group-map table of the skills catalog README."
)]
struct Args {
    /// Path to the catalog README.md (contains the group-map table)
    readme: PathBuf,

    /// Skill name (appended to the group's row, wrapped in backticks)
    #[arg(long)]
    name: String,

    /// Group slug — must match the skill's `group:` frontmatter
    #[arg(long)]
    group: String,
}

fn main() -> Result<ExitCode> {
    let args = Args::parse();

    if !rules::ALLOWED_GROUPS.contains(&args.group.as_str()) {
        eprintln!(
            "error: unknown group '{}' — allowed: {}",
            args.group,
            rules::ALLOWED_GROUPS.join(", ")
        );
        return Ok(ExitCode::FAILURE);
    }

    match register(&args.readme, &args.name, &args.group)? {
        Outcome::Added => {
            println!(
                "✓ registered `{}` under `{}` in {}",
                args.name,
                args.group,
                args.readme.display()
            );
        }
        Outcome::AlreadyPresent => {
            println!(
                "• `{}` already listed under `{}` in {} — no-op",
                args.name,
                args.group,
                args.readme.display()
            );
        }
    }
    Ok(ExitCode::SUCCESS)
}

enum Outcome {
    Added,
    AlreadyPresent,
}

fn register(readme: &Path, name: &str, group: &str) -> Result<Outcome> {
    let content = fs::read_to_string(readme)
        .with_context(|| format!("failed to read {}", readme.display()))?;

    let lines: Vec<&str> = content.lines().collect();
    let marker = format!("`{name}`");
    let group_cell = format!("`{group}`");

    let mut target: Option<usize> = None;
    for (i, line) in lines.iter().enumerate() {
        let Some(cells) = parse_row(line) else {
            continue;
        };
        if cells.len() < 3 || !rules::ALLOWED_GROUPS.contains(&cells[0].trim_matches('`')) {
            continue;
        }
        if cells[2].contains(&marker) {
            if cells[0] == group_cell {
                return Ok(Outcome::AlreadyPresent);
            }
            return Err(anyhow!(
                "`{name}` is already registered under {} — remove it from that row first",
                cells[0]
            ));
        }
        if cells[0] == group_cell {
            target = Some(i);
        }
    }

    let target = target.ok_or_else(|| {
        anyhow!(
            "group row `{group}` not found in {} — is this the catalog README?",
            readme.display()
        )
    })?;

    let new_line = append_to_row(lines[target], name);
    let mut out = String::with_capacity(content.len() + marker.len() + 4);
    for (i, line) in lines.iter().enumerate() {
        if i == target {
            out.push_str(&new_line);
        } else {
            out.push_str(line);
        }
        out.push('\n');
    }
    if !content.ends_with('\n') {
        out.pop();
    }

    fs::write(readme, out)
        .with_context(|| format!("failed to write {}", readme.display()))?;
    Ok(Outcome::Added)
}

/// Parse a markdown table row into trimmed cells; None for non-row lines.
fn parse_row(line: &str) -> Option<Vec<String>> {
    let t = line.trim();
    if !t.starts_with('|') || !t.ends_with('|') || t.len() < 2 {
        return None;
    }
    let inner = &t[1..t.len() - 1];
    Some(inner.split('|').map(|c| c.trim().to_string()).collect())
}

/// Append `name` to the last cell of a table row, preserving the rest verbatim.
fn append_to_row(line: &str, name: &str) -> String {
    let t = line.trim_end();
    let body = t.strip_suffix('|').unwrap_or(t).trim_end();
    if body.ends_with('|') {
        // last cell was empty
        format!("{body} `{name}` |")
    } else {
        format!("{body}, `{name}` |")
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    fn sample_readme() -> String {
        "# Skills\n\n## 그룹\n\n| slug | 한글 라벨 | 자체 스킬 |\n| --- | --- | --- |\n| `docs` | 📝 문서·커밋 | `commit`, `generate-claude-md` |\n| `meta` | 🧪 메타·관리 | `skill-index`, `generate-skills` |\n\ntail text\n".to_string()
    }

    fn tmpfile(tag: &str, body: &str) -> PathBuf {
        let dir = std::env::temp_dir();
        let path = dir.join(format!(
            "register-skill-test-{}-{}.md",
            std::process::id(),
            tag
        ));
        let mut f = fs::File::create(&path).unwrap();
        f.write_all(body.as_bytes()).unwrap();
        path
    }

    #[test]
    fn adds_to_matching_group_row() {
        let path = tmpfile("add", &sample_readme());
        let outcome = register(&path, "skill-improver", "meta").unwrap();
        assert!(matches!(outcome, Outcome::Added));
        let after = fs::read_to_string(&path).unwrap();
        assert!(after.contains(
            "| `meta` | 🧪 메타·관리 | `skill-index`, `generate-skills`, `skill-improver` |"
        ));
        assert!(after.contains("| `docs` | 📝 문서·커밋 | `commit`, `generate-claude-md` |"));
        fs::remove_file(&path).ok();
    }

    #[test]
    fn idempotent_when_already_listed() {
        let path = tmpfile("idempotent", &sample_readme());
        let outcome = register(&path, "commit", "docs").unwrap();
        assert!(matches!(outcome, Outcome::AlreadyPresent));
        let after = fs::read_to_string(&path).unwrap();
        assert_eq!(after, sample_readme());
        fs::remove_file(&path).ok();
    }

    #[test]
    fn errors_when_listed_under_other_group() {
        let path = tmpfile("conflict", &sample_readme());
        let result = register(&path, "commit", "meta");
        assert!(result.is_err());
        fs::remove_file(&path).ok();
    }

    #[test]
    fn errors_when_group_row_missing() {
        let path = tmpfile("nogroup", "# No table here\n\ntext only\n");
        let result = register(&path, "foo", "meta");
        assert!(result.is_err());
        fs::remove_file(&path).ok();
    }

    #[test]
    fn appends_into_empty_cell() {
        let body =
            "| slug | label | skills |\n| --- | --- | --- |\n| `llm` | 🤖 외부 LLM | |\n";
        let path = tmpfile("empty", body);
        let outcome = register(&path, "gemma", "llm").unwrap();
        assert!(matches!(outcome, Outcome::Added));
        let after = fs::read_to_string(&path).unwrap();
        assert!(after.contains("| `llm` | 🤖 외부 LLM | `gemma` |"));
        fs::remove_file(&path).ok();
    }
}
