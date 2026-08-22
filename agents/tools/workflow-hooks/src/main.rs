mod archive;
mod contract;

use contract::{Artifact, WorkflowContract};
use serde_json::{Value, json};
use std::collections::{BTreeSet, HashSet};
use std::env;
use std::fs;
use std::io::{self, Read};
use std::path::{Path, PathBuf};
use std::process::{self, Command};
use std::time::{SystemTime, UNIX_EPOCH};

const CLARIFY_MESSAGE: &str = "Reminder: prompt contains '업데이트/변경사항' — per shared guidance, confirm whether the user means 'commit' or 'update content' before proceeding.";
const ANNOTATION_MESSAGE: &str = "A research or plan document was written. Prompt the user to review it before proceeding, and do not move to implementation until the user confirms.";

enum HookOutput {
    Json(Value),
    Block(String),
}

fn main() {
    let Some(action) = env::args().nth(1) else {
        usage();
    };
    let input = if action == "contract" {
        json!({})
    } else {
        read_input().unwrap_or_else(|_| usage())
    };
    let contract = contract::load().unwrap_or_else(|error| {
        eprintln!("{}", json!({ "error": error }));
        process::exit(1);
    });

    let result = match action.as_str() {
        "contract" => serde_json::to_value(&contract).map_err(|error| error.to_string()),
        "cadence" => cadence(&contract),
        "clarify" => Ok(clarify(&input)),
        "annotation" => Ok(annotation(&input, &contract)),
        "context" => context(&input, &contract),
        "typecheck" => typecheck(&input, &contract),
        "archive" => archive::run(&input, &contract),
        "hook" => match native_hook(&input, &contract) {
            Ok(HookOutput::Json(value)) => Ok(value),
            Ok(HookOutput::Block(message)) => {
                eprintln!("{message}");
                process::exit(2);
            }
            Err(error) => Err(error),
        },
        _ => usage(),
    };

    match result {
        Ok(value) => println!("{value}"),
        Err(error) => {
            eprintln!("{}", json!({ "error": error }));
            process::exit(1);
        }
    }
}

fn usage() -> ! {
    eprintln!(
        "usage: workflow-hooks <contract|hook|cadence|clarify|annotation|context|typecheck|archive> < input.json"
    );
    process::exit(2);
}

fn read_input() -> Result<Value, String> {
    let mut input = String::new();
    io::stdin()
        .read_to_string(&mut input)
        .map_err(|error| error.to_string())?;
    let value: Value = serde_json::from_str(&input).map_err(|error| error.to_string())?;
    value
        .is_object()
        .then_some(value)
        .ok_or_else(|| "input must be a JSON object".to_string())
}

fn string<'a>(input: &'a Value, key: &str) -> Option<&'a str> {
    input.get(key).and_then(Value::as_str)
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

fn message(message: impl Into<String>) -> Value {
    json!({ "message": message.into() })
}

fn additional_context(event: &str, result: Value) -> Value {
    let Some(text) = result.get("message").and_then(Value::as_str) else {
        return json!({});
    };
    json!({
        "hookSpecificOutput": {
            "hookEventName": event,
            "additionalContext": text
        }
    })
}

fn cadence(contract: &WorkflowContract) -> Result<Value, String> {
    let Some(home) = env::var_os("HOME").map(PathBuf::from) else {
        return Ok(json!({}));
    };
    let cadence = &contract.maintenance.skill_improver;
    let stamp = home.join(
        cadence
            .timestamp
            .strip_prefix("~/")
            .ok_or_else(|| "skill-improver timestamp must start with ~/".to_string())?,
    );
    let mut elapsed = "실행 기록 없음".to_string();

    if let Ok(contents) = fs::read_to_string(&stamp) {
        if let Some(last) = contents.lines().next().and_then(date_days) {
            let now = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map_err(|error| error.to_string())?
                .as_secs() as i64
                / 86_400;
            let days = now - last;
            if days <= cadence.interval_days {
                return Ok(json!({}));
            }
            elapsed = format!("{days}일 경과");
        }
    }

    let skills = home.join(".claude/skills");
    let count = fs::read_dir(skills)
        .into_iter()
        .flatten()
        .filter_map(Result::ok)
        .filter(|entry| entry.path().join("SKILL.md").is_file())
        .count();
    Ok(message(format!(
        "skill-improver cadence check: surface a short, non-blocking notice — \"마지막 skill-improver 실행 후 {elapsed}, {count}개 스킬 점검 가능. 지금 실행할까요?\" Do not auto-run without consent. On consent, invoke the skill-improver skill through the active harness and do not write the timestamp; the skill writes it only after successful completion. On decline or dismissal, write today's UTC date (YYYY-MM-DD) to ~/.claude/.last_skill_improver_run so the prompt does not repeat next session."
    )))
}

fn date_days(value: &str) -> Option<i64> {
    let mut parts = value.trim().split('-').map(str::parse::<i64>);
    let year = parts.next()?.ok()?;
    let month = parts.next()?.ok()?;
    let day = parts.next()?.ok()?;
    if parts.next().is_some() || !(1..=12).contains(&month) {
        return None;
    }
    let leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    let max_day = match month {
        2 if leap => 29,
        2 => 28,
        4 | 6 | 9 | 11 => 30,
        _ => 31,
    };
    if !(1..=max_day).contains(&day) {
        return None;
    }

    let adjusted_year = year - i64::from(month <= 2);
    let era = if adjusted_year >= 0 {
        adjusted_year
    } else {
        adjusted_year - 399
    } / 400;
    let year_of_era = adjusted_year - era * 400;
    let shifted_month = month + if month > 2 { -3 } else { 9 };
    let day_of_year = (153 * shifted_month + 2) / 5 + day - 1;
    let day_of_era = year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year;
    Some(era * 146_097 + day_of_era - 719_468)
}

fn clarify(input: &Value) -> Value {
    let prompt = string(input, "prompt").unwrap_or_default();
    if prompt.contains("업데이트") || prompt.contains("변경사항") {
        message(CLARIFY_MESSAGE)
    } else {
        json!({})
    }
}

fn annotation(input: &Value, contract: &WorkflowContract) -> Value {
    let cwd = string(input, "cwd").map(PathBuf::from);
    let files = strings(input, "files");
    if files.iter().any(|file| {
        ["spec", "contract", "research", "plan"]
            .iter()
            .any(|name| written_path_matches(file, cwd.as_deref(), contract, name))
    }) {
        message(ANNOTATION_MESSAGE)
    } else {
        json!({})
    }
}

fn written_path_matches(
    file: &str,
    cwd: Option<&Path>,
    contract: &WorkflowContract,
    name: &str,
) -> bool {
    let normalized = file.replace('\\', "/");
    let path = Path::new(&normalized);
    let relative = cwd
        .and_then(|root| path.strip_prefix(root).ok())
        .unwrap_or(path)
        .to_string_lossy();
    if contract.matches_artifact(name, relative.trim_start_matches("./")) {
        return true;
    }

    let Ok(artifact) = contract.artifact(name) else {
        return false;
    };
    let Some(template) = artifact.template() else {
        return false;
    };
    if artifact.path.is_some() {
        normalized == template || normalized.ends_with(&format!("/{template}"))
    } else {
        let parent = Path::new(template)
            .parent()
            .and_then(Path::to_str)
            .unwrap_or_default();
        normalized
            .rfind(&format!("/{parent}/"))
            .is_some_and(|index| contract.matches_artifact(name, &normalized[index + 1..]))
    }
}

fn context(input: &Value, contract: &WorkflowContract) -> Result<Value, String> {
    let cwd = match canonical_cwd(input) {
        Ok(cwd) => cwd,
        Err(_) => return Ok(json!({})),
    };
    let mut files = Vec::new();
    for (name, artifact) in &contract.artifacts {
        if artifact.context {
            collect_contract_artifact(&cwd, name, artifact, contract, &mut files)?;
        }
    }
    files.sort();
    files.dedup();

    let mut entries: Vec<String> = files
        .into_iter()
        .filter_map(|path| {
            let contents = fs::read_to_string(&path).ok()?;
            let title = contents
                .lines()
                .find(|line| line.starts_with('#'))
                .map(|line| line.trim_start_matches('#').trim_start())
                .filter(|title| !title.is_empty())
                .map(str::to_owned)
                .or_else(|| path.file_name()?.to_str().map(str::to_owned))?;
            Some(format!("- {}: {title}", path.display()))
        })
        .collect();
    if cwd
        .join(contract.transient("implementation_flag")?)
        .is_file()
    {
        entries.push("- .plans/.implementing: implementation is active".to_string());
    }

    let legacy_warning = cwd.join(".harness").exists().then_some(
        "Legacy .harness workflow state detected. Managed workflow creation must stop until the user preserves, manually translates, or removes it; never migrate it automatically.",
    );

    if entries.is_empty() && legacy_warning.is_none() {
        Ok(json!({}))
    } else {
        let mut contents = if entries.is_empty() {
            String::new()
        } else {
            format!(
                "Active workflow artifacts:\n{}\nRefer to these files for active workflow context.",
                entries.join("\n")
            )
        };
        if let Some(warning) = legacy_warning {
            if !contents.is_empty() {
                contents.push_str("\n\n");
            }
            contents.push_str(warning);
        }
        Ok(message(contents))
    }
}

fn collect_contract_artifact(
    cwd: &Path,
    name: &str,
    artifact: &Artifact,
    contract: &WorkflowContract,
    files: &mut Vec<PathBuf>,
) -> Result<(), String> {
    if let Some(path) = &artifact.path {
        let candidate = cwd.join(path);
        if candidate.is_file() {
            files.push(candidate);
        }
        return Ok(());
    }

    let pattern = artifact
        .pattern
        .as_deref()
        .ok_or_else(|| format!("artifact has no path or pattern: {name}"))?;
    let parent = Path::new(pattern)
        .parent()
        .ok_or_else(|| format!("artifact pattern has no parent: {pattern}"))?;
    let Ok(entries) = fs::read_dir(cwd.join(parent)) else {
        return Ok(());
    };
    files.extend(entries.filter_map(Result::ok).filter_map(|entry| {
        let path = entry.path();
        let relative = path.strip_prefix(cwd).ok()?.to_str()?;
        (path.is_file() && contract.matches_artifact(name, relative)).then_some(path)
    }));
    Ok(())
}

fn canonical_cwd(input: &Value) -> Result<PathBuf, String> {
    let cwd = string(input, "cwd").unwrap_or(".");
    fs::canonicalize(cwd).map_err(|_| format!("cwd does not exist: {cwd}"))
}

fn typecheck(input: &Value, contract: &WorkflowContract) -> Result<Value, String> {
    let cwd = match canonical_cwd(input) {
        Ok(cwd) => cwd,
        Err(_) => return Ok(json!({})),
    };
    if !cwd
        .join(contract.transient("implementation_flag")?)
        .is_file()
    {
        return Ok(json!({}));
    }

    let mut errors = Vec::new();
    let mut seen = HashSet::new();
    for file in strings(input, "files") {
        let path = if Path::new(&file).is_absolute() {
            PathBuf::from(file)
        } else {
            cwd.join(file)
        };
        if !path.is_file() {
            continue;
        }
        let Some(extension) = path.extension().and_then(|value| value.to_str()) else {
            continue;
        };
        let directory = path.parent().unwrap_or(&cwd);
        let (key, check_directory, command, arguments): (String, PathBuf, &str, Vec<String>) =
            match extension {
                "py" => (
                    format!("py:{}", path.display()),
                    find_ancestor(directory, "pyproject.toml")
                        .unwrap_or_else(|| directory.to_owned()),
                    "mypy",
                    vec![path.display().to_string()],
                ),
                "rs" => {
                    let Some(root) = find_ancestor(directory, "Cargo.toml") else {
                        continue;
                    };
                    (
                        format!("rs:{}", root.display()),
                        root,
                        "cargo",
                        vec!["check".to_string()],
                    )
                }
                "go" => {
                    let root =
                        find_ancestor(directory, "go.mod").unwrap_or_else(|| directory.to_owned());
                    (
                        format!("go:{}", root.display()),
                        root,
                        "go",
                        vec!["vet".to_string(), "./...".to_string()],
                    )
                }
                _ => continue,
            };
        if seen.insert(key) {
            if let Some(error) = run_check(command, &arguments, &check_directory) {
                errors.push(error);
            }
        }
    }

    if errors.is_empty() {
        Ok(json!({}))
    } else {
        Ok(json!({ "block": true, "message": errors.join("\n\n") }))
    }
}

fn find_ancestor(start: &Path, marker: &str) -> Option<PathBuf> {
    let mut directory = start.to_owned();
    loop {
        if directory.join(marker).is_file() {
            return Some(directory);
        }
        if !directory.pop() {
            return None;
        }
    }
}

fn run_check(command: &str, arguments: &[String], directory: &Path) -> Option<String> {
    match Command::new(command)
        .args(arguments)
        .current_dir(directory)
        .output()
    {
        Ok(output) if output.status.success() => None,
        Ok(output) => {
            let mut text = String::from_utf8_lossy(&output.stdout).into_owned();
            text.push_str(&String::from_utf8_lossy(&output.stderr));
            Some(text.trim_end().to_string())
        }
        Err(error) => Some(format!("{command}: {error}")),
    }
}

fn native_hook(input: &Value, contract: &WorkflowContract) -> Result<HookOutput, String> {
    let event = string(input, "hook_event_name").unwrap_or_default();
    match event {
        "SessionStart" => {
            let result = if string(input, "source") == Some("compact") {
                context(input, contract)?
            } else {
                cadence(contract)?
            };
            Ok(HookOutput::Json(additional_context("SessionStart", result)))
        }
        "UserPromptSubmit" => Ok(HookOutput::Json(additional_context(
            "UserPromptSubmit",
            clarify(input),
        ))),
        "PostToolUse" => {
            let files = native_files(input);
            let normalized = json!({
                "cwd": string(input, "cwd").unwrap_or("."),
                "files": files
            });
            let annotation = annotation(&normalized, contract);
            let typecheck = typecheck(&normalized, contract)?;
            if typecheck.get("block").and_then(Value::as_bool) == Some(true) {
                let mut messages = Vec::new();
                if let Some(value) = annotation.get("message").and_then(Value::as_str) {
                    messages.push(value);
                }
                if let Some(value) = typecheck.get("message").and_then(Value::as_str) {
                    messages.push(value);
                }
                Ok(HookOutput::Block(messages.join("\n\n")))
            } else {
                Ok(HookOutput::Json(additional_context(
                    "PostToolUse",
                    annotation,
                )))
            }
        }
        _ => Ok(HookOutput::Json(json!({}))),
    }
}

fn native_files(input: &Value) -> Vec<String> {
    if let Some(path) = input
        .get("tool_input")
        .and_then(|value| value.get("file_path"))
        .and_then(Value::as_str)
    {
        return vec![path.to_string()];
    }

    let command = input
        .get("tool_input")
        .and_then(|value| value.get("command"))
        .and_then(Value::as_str)
        .unwrap_or_default();
    let prefixes = [
        "*** Add File: ",
        "*** Update File: ",
        "*** Delete File: ",
        "*** Move to: ",
    ];
    command
        .lines()
        .filter_map(|line| prefixes.iter().find_map(|prefix| line.strip_prefix(prefix)))
        .map(str::to_owned)
        .collect::<BTreeSet<_>>()
        .into_iter()
        .collect()
}

#[cfg(test)]
mod tests {
    use super::{date_days, native_files};
    use serde_json::json;

    #[test]
    fn parses_unix_epoch_date() {
        assert_eq!(date_days("1970-01-01"), Some(0));
        assert_eq!(date_days("2024-02-29"), Some(19_782));
        assert_eq!(date_days("2023-02-29"), None);
    }

    #[test]
    fn extracts_unique_patch_paths() {
        let input = json!({
            "tool_input": {
                "command": "*** Update File: a.md\n*** Move to: b.md\n*** Update File: a.md"
            }
        });
        assert_eq!(native_files(&input), vec!["a.md", "b.md"]);
    }
}
