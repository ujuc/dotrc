use crate::contract::WorkflowContract;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::fs;
use std::io;
use std::path::{Component, Path, PathBuf};

const WORKFLOW_SOURCES_ERROR: &str = "Workflow Sources must use exactly: Product Spec, Sprint Contract, and Research with canonical backticked paths or None";

#[derive(Debug, PartialEq)]
struct WorkflowSources {
    spec: Option<String>,
    contract: Option<String>,
    research: Vec<String>,
}

struct Move {
    source: PathBuf,
    destination: PathBuf,
    relative_destination: String,
}

pub fn run(input: &Value, contract: &WorkflowContract) -> Result<Value, String> {
    let cwd_value = input.get("cwd").and_then(Value::as_str).unwrap_or(".");
    let cwd = fs::canonicalize(cwd_value)
        .map_err(|_| format!("Archive cwd does not exist: {cwd_value}"))?;
    let relative_plan = required_string(input, "plan")?;
    validate_artifact_source(contract, "plan", relative_plan)?;

    let plan_path = Path::new(relative_plan);
    let plan_name = plan_path
        .file_name()
        .and_then(|value| value.to_str())
        .ok_or_else(|| format!("Invalid plan path: {relative_plan}"))?;
    let feature = plan_name
        .strip_prefix("plan-")
        .and_then(|value| value.strip_suffix(".md"))
        .filter(|value| !value.is_empty())
        .ok_or_else(|| format!("Invalid plan feature: {relative_plan}"))?;
    validate_slug("plan feature", feature)?;

    let source_plan = cwd.join(plan_path);
    require_file(&source_plan, relative_plan)?;
    let plan_contents = fs::read_to_string(&source_plan).map_err(|error| error.to_string())?;
    let sources = workflow_sources(&cwd, feature, &plan_contents)?;

    let item_slugs = strings(input, "item_slugs");
    for slug in &item_slugs {
        validate_slug("item slug", slug)?;
    }

    let mut moves = Vec::new();
    if let Some(source) = sources.spec {
        moves.push(artifact_move(
            &cwd,
            contract,
            "spec",
            &source,
            contract.render_archive("spec", feature)?,
        )?);
    }
    if let Some(source) = sources.contract {
        moves.push(artifact_move(
            &cwd,
            contract,
            "contract",
            &source,
            contract.render_archive("contract", feature)?,
        )?);
    }
    for source in sources.research {
        let file_name = Path::new(&source)
            .file_name()
            .and_then(|value| value.to_str())
            .ok_or_else(|| format!("Invalid research source: {source}"))?;
        let destination = format!("{}/{file_name}", contract.archive("research_directory")?);
        moves.push(artifact_move(
            &cwd,
            contract,
            "research",
            &source,
            destination,
        )?);
    }

    if let Some(final_report) = input.get("final_report").and_then(Value::as_str) {
        validate_artifact_source(contract, "evaluation_report", final_report)?;
        if !final_report_matches(final_report, feature) {
            return Err(format!(
                "Final report does not match plan feature {feature}: {final_report}"
            ));
        }
        moves.push(artifact_move(
            &cwd,
            contract,
            "evaluation_report",
            final_report,
            contract.render_archive("evaluation_report", feature)?,
        )?);
    }

    let plan_destination = format!("{}/{plan_name}", contract.archive("plan_directory")?);
    moves.push(artifact_move(
        &cwd,
        contract,
        "plan",
        relative_plan,
        plan_destination,
    )?);

    preflight_moves(&moves)?;
    for movement in &moves {
        let parent = movement.destination.parent().ok_or_else(|| {
            format!(
                "Archive destination has no parent: {}",
                movement.relative_destination
            )
        })?;
        fs::create_dir_all(parent).map_err(|error| error.to_string())?;
    }

    let mut completed = Vec::new();
    for movement in &moves {
        if let Err(error) = fs::rename(&movement.source, &movement.destination) {
            let rollback_errors = rollback(&completed);
            let suffix = if rollback_errors.is_empty() {
                String::new()
            } else {
                format!("; rollback errors: {}", rollback_errors.join("; "))
            };
            return Err(format!(
                "Failed to move {}: {error}{suffix}",
                movement.relative_destination
            ));
        }
        completed.push((&movement.source, &movement.destination));
    }

    cleanup(&cwd, contract, feature, &item_slugs)?;
    Ok(json!({
        "moved": moves
            .iter()
            .map(|movement| movement.relative_destination.as_str())
            .collect::<Vec<_>>()
    }))
}

fn workflow_sources(cwd: &Path, feature: &str, plan: &str) -> Result<WorkflowSources, String> {
    if let Some(lines) = section(plan, "## Workflow Sources") {
        return parse_workflow_sources(&lines);
    }

    let research = if let Some(lines) = section(plan, "## Research Sources") {
        parse_legacy_research(&lines)?
    } else {
        let inferred = format!(".research/research-{feature}.md");
        cwd.join(&inferred)
            .is_file()
            .then_some(inferred)
            .into_iter()
            .collect()
    };
    Ok(WorkflowSources {
        spec: None,
        contract: None,
        research,
    })
}

fn section<'a>(contents: &'a str, heading: &str) -> Option<Vec<&'a str>> {
    let mut found = false;
    let mut lines = Vec::new();
    for line in contents.lines() {
        if line.trim_end() == heading {
            found = true;
            continue;
        }
        if found && line.starts_with("## ") {
            break;
        }
        if found {
            lines.push(line.trim_end());
        }
    }
    found.then_some(lines)
}

fn parse_workflow_sources(lines: &[&str]) -> Result<WorkflowSources, String> {
    let lines: Vec<&str> = lines
        .iter()
        .copied()
        .filter(|line| !line.is_empty())
        .collect();
    if lines.len() < 3 {
        return Err(WORKFLOW_SOURCES_ERROR.to_string());
    }

    let spec = lines[0]
        .strip_prefix("- Product Spec: ")
        .ok_or_else(|| WORKFLOW_SOURCES_ERROR.to_string())?;
    let contract = lines[1]
        .strip_prefix("- Sprint Contract: ")
        .ok_or_else(|| WORKFLOW_SOURCES_ERROR.to_string())?;
    let spec = parse_optional_path(spec)?;
    let contract = parse_optional_path(contract)?;

    let research = if lines[2] == "- Research: None" {
        if lines.len() != 3 {
            return Err(WORKFLOW_SOURCES_ERROR.to_string());
        }
        Vec::new()
    } else if lines[2] == "- Research:" {
        if lines.len() == 3 {
            return Err(WORKFLOW_SOURCES_ERROR.to_string());
        }
        lines[3..]
            .iter()
            .map(|line| {
                line.strip_prefix("  - ")
                    .ok_or_else(|| WORKFLOW_SOURCES_ERROR.to_string())
                    .and_then(parse_backticked_path)
            })
            .collect::<Result<Vec<_>, _>>()?
    } else {
        return Err(WORKFLOW_SOURCES_ERROR.to_string());
    };

    Ok(WorkflowSources {
        spec,
        contract,
        research,
    })
}

fn parse_legacy_research(lines: &[&str]) -> Result<Vec<String>, String> {
    let lines: Vec<&str> = lines
        .iter()
        .copied()
        .filter(|line| !line.is_empty())
        .collect();
    if lines == ["None"] {
        return Ok(Vec::new());
    }
    if lines.is_empty() {
        return Err("Research Sources must contain exact backticked paths or None".to_string());
    }
    lines
        .iter()
        .map(|line| {
            line.strip_prefix("- ")
                .ok_or_else(|| {
                    "Research Sources must contain exact backticked paths or None".to_string()
                })
                .and_then(parse_backticked_path)
        })
        .collect()
}

fn parse_optional_path(value: &str) -> Result<Option<String>, String> {
    if value == "None" {
        Ok(None)
    } else {
        parse_backticked_path(value).map(Some)
    }
}

fn parse_backticked_path(value: &str) -> Result<String, String> {
    value
        .strip_prefix('`')
        .and_then(|value| value.strip_suffix('`'))
        .filter(|value| !value.is_empty() && !value.contains('`'))
        .map(str::to_owned)
        .ok_or_else(|| WORKFLOW_SOURCES_ERROR.to_string())
}

fn artifact_move(
    cwd: &Path,
    contract: &WorkflowContract,
    artifact: &str,
    relative_source: &str,
    relative_destination: String,
) -> Result<Move, String> {
    validate_artifact_source(contract, artifact, relative_source)?;
    let source = cwd.join(relative_source);
    require_file(&source, relative_source)?;
    Ok(Move {
        source,
        destination: cwd.join(&relative_destination),
        relative_destination,
    })
}

fn validate_artifact_source(
    contract: &WorkflowContract,
    artifact: &str,
    value: &str,
) -> Result<(), String> {
    validate_relative(value)?;
    let definition = contract.artifact(artifact)?;
    let template = definition
        .template()
        .ok_or_else(|| format!("Artifact has no path or pattern: {artifact}"))?;
    if !contract.matches_artifact(artifact, value)
        || Path::new(value).parent() != Path::new(template).parent()
    {
        return Err(format!("Invalid {artifact} source: {value}"));
    }
    Ok(())
}

fn validate_relative(value: &str) -> Result<(), String> {
    if value.is_empty()
        || Path::new(value).components().any(|component| {
            matches!(
                component,
                Component::Prefix(_)
                    | Component::RootDir
                    | Component::ParentDir
                    | Component::CurDir
            )
        })
    {
        Err(format!("Source must be a safe relative path: {value}"))
    } else {
        Ok(())
    }
}

fn preflight_moves(moves: &[Move]) -> Result<(), String> {
    let mut sources = BTreeSet::new();
    let mut destinations = BTreeSet::new();
    for movement in moves {
        if !sources.insert(&movement.source) {
            return Err(format!(
                "Duplicate archive source: {}",
                movement.source.display()
            ));
        }
        if !destinations.insert(&movement.destination) {
            return Err(format!(
                "Duplicate archive destination: {}",
                movement.relative_destination
            ));
        }
        ensure_absent(&movement.destination, &movement.relative_destination)?;
    }
    Ok(())
}

fn cleanup(
    cwd: &Path,
    contract: &WorkflowContract,
    feature: &str,
    item_slugs: &[String],
) -> Result<(), String> {
    for slug in item_slugs {
        for prefix in ["verify", "blocker", "debug"] {
            remove_if_exists(&cwd.join(format!(".plans/.{prefix}-{slug}.md")))?;
        }
    }

    let exact = [
        contract.transient("implementation_flag")?.to_string(),
        contract
            .transient("plan_baseline_pattern")?
            .replace('*', feature),
        contract
            .transient("plan_cycle_pattern")?
            .replace('*', feature),
        format!(".plans/.verify-final-{feature}.md"),
        format!(".plans/.handoff-{feature}.md"),
    ];
    for relative in exact {
        remove_if_exists(&cwd.join(relative))?;
    }

    let plans = cwd.join(".plans");
    let Ok(entries) = fs::read_dir(&plans) else {
        return Ok(());
    };
    let prefixes = [
        format!(".qa-{feature}-r"),
        format!(".design-{feature}-r"),
        format!(".evaluation-{feature}-r"),
    ];
    for entry in entries.filter_map(Result::ok) {
        let path = entry.path();
        let Some(name) = path.file_name().and_then(|value| value.to_str()) else {
            continue;
        };
        if path.is_file()
            && name.ends_with(".md")
            && prefixes.iter().any(|prefix| name.starts_with(prefix))
        {
            remove_if_exists(&path)?;
        }
    }
    Ok(())
}

fn required_string<'a>(input: &'a Value, key: &str) -> Result<&'a str, String> {
    input
        .get(key)
        .and_then(Value::as_str)
        .filter(|value| !value.is_empty())
        .ok_or_else(|| format!("Missing required string: {key}"))
}

fn final_report_matches(value: &str, feature: &str) -> bool {
    value
        .strip_prefix(&format!(".plans/.evaluation-{feature}-r"))
        .and_then(|value| value.strip_suffix(".md"))
        .is_some_and(|round| !round.is_empty() && round.bytes().all(|byte| byte.is_ascii_digit()))
}

fn strings(input: &Value, key: &str) -> Vec<String> {
    input
        .get(key)
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
        .map(str::to_owned)
        .collect()
}

fn validate_slug(kind: &str, value: &str) -> Result<(), String> {
    if value.is_empty()
        || !value
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || b"._-".contains(&byte))
    {
        Err(format!("Invalid {kind}: {value}"))
    } else {
        Ok(())
    }
}

fn require_file(path: &Path, relative: &str) -> Result<(), String> {
    path.is_file()
        .then_some(())
        .ok_or_else(|| format!("Declared source does not exist: {relative}"))
}

fn ensure_absent(path: &Path, relative: &str) -> Result<(), String> {
    match fs::symlink_metadata(path) {
        Ok(_) => Err(format!("Archive destination exists: {relative}")),
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(()),
        Err(error) => Err(error.to_string()),
    }
}

fn rollback(moved: &[(&PathBuf, &PathBuf)]) -> Vec<String> {
    moved
        .iter()
        .rev()
        .filter_map(|(source, destination)| {
            fs::rename(destination, source)
                .err()
                .map(|error| format!("{}: {error}", destination.display()))
        })
        .collect()
}

fn remove_if_exists(path: &Path) -> Result<(), String> {
    match fs::remove_file(path) {
        Ok(()) => Ok(()),
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(()),
        Err(error) => Err(error.to_string()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_complete_workflow_sources() {
        let sources = parse_workflow_sources(&[
            "- Product Spec: `spec.md`",
            "- Sprint Contract: `.sprint/contract.md`",
            "- Research:",
            "  - `.research/research-demo.md`",
        ])
        .unwrap();
        assert_eq!(sources.spec.as_deref(), Some("spec.md"));
        assert_eq!(sources.contract.as_deref(), Some(".sprint/contract.md"));
        assert_eq!(sources.research, [".research/research-demo.md"]);
    }

    #[test]
    fn rejects_missing_workflow_source_label() {
        let error = parse_workflow_sources(&[
            "- Product Spec: None",
            "- Research: None",
            "- Sprint Contract: None",
        ])
        .unwrap_err();
        assert_eq!(error, WORKFLOW_SOURCES_ERROR);
    }

    #[test]
    fn final_report_round_must_be_numeric() {
        assert!(final_report_matches(
            ".plans/.evaluation-demo-r12.md",
            "demo"
        ));
        assert!(!final_report_matches(
            ".plans/.evaluation-demo-rreview.md",
            "demo"
        ));
        assert!(!final_report_matches(
            ".plans/.evaluation-other-r1.md",
            "demo"
        ));
    }
}
