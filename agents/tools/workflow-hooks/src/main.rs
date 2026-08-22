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
    let input = read_input().unwrap_or_else(|_| usage());

    let result = match action.as_str() {
        "cadence" => cadence(),
        "clarify" => Ok(clarify(&input)),
        "annotation" => Ok(annotation(strings(&input, "files"))),
        "context" => context(&input),
        "typecheck" => typecheck(&input),
        "archive" => archive(&input),
        "hook" => match native_hook(&input) {
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
        "usage: workflow-hooks <hook|cadence|clarify|annotation|context|typecheck|archive> < input.json"
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

fn cadence() -> Result<Value, String> {
    let Some(home) = env::var_os("HOME").map(PathBuf::from) else {
        return Ok(json!({}));
    };
    let stamp = home.join(".claude/.last_skill_improver_run");
    let mut elapsed = "실행 기록 없음".to_string();

    if let Ok(contents) = fs::read_to_string(&stamp) {
        if let Some(last) = contents.lines().next().and_then(date_days) {
            let now = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map_err(|error| error.to_string())?
                .as_secs() as i64
                / 86_400;
            let days = now - last;
            if days <= 7 {
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

fn annotation(files: Vec<String>) -> Value {
    if files.iter().any(|file| {
        let path = file.replace('\\', "/");
        let research = path.starts_with(".research/") || path.contains("/.research/");
        let plan = path.starts_with(".plans/plan-") || path.contains("/.plans/plan-");
        path.ends_with(".md") && (research || plan)
    }) {
        message(ANNOTATION_MESSAGE)
    } else {
        json!({})
    }
}

fn context(input: &Value) -> Result<Value, String> {
    let cwd = match canonical_cwd(input) {
        Ok(cwd) => cwd,
        Err(_) => return Ok(json!({})),
    };
    let mut files = Vec::new();
    collect_artifacts(
        &cwd.join(".research"),
        |name| name.ends_with(".md"),
        &mut files,
    );
    collect_artifacts(
        &cwd.join(".plans"),
        |name| name.starts_with("plan-") && name.ends_with(".md"),
        &mut files,
    );
    files.sort();

    let entries: Vec<String> = files
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

    if entries.is_empty() {
        Ok(json!({}))
    } else {
        Ok(message(format!(
            "Active research/plan artifacts:\n{}\nRefer to these files for active workflow context.",
            entries.join("\n")
        )))
    }
}

fn collect_artifacts(directory: &Path, matches: impl Fn(&str) -> bool, files: &mut Vec<PathBuf>) {
    let Ok(entries) = fs::read_dir(directory) else {
        return;
    };
    files.extend(entries.filter_map(Result::ok).filter_map(|entry| {
        let path = entry.path();
        let name = path.file_name()?.to_str()?;
        (path.is_file() && matches(name)).then_some(path)
    }));
}

fn canonical_cwd(input: &Value) -> Result<PathBuf, String> {
    let cwd = string(input, "cwd").unwrap_or(".");
    fs::canonicalize(cwd).map_err(|_| format!("cwd does not exist: {cwd}"))
}

fn typecheck(input: &Value) -> Result<Value, String> {
    let cwd = match canonical_cwd(input) {
        Ok(cwd) => cwd,
        Err(_) => return Ok(json!({})),
    };
    if !cwd.join(".plans/.implementing").is_file() {
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

fn native_hook(input: &Value) -> Result<HookOutput, String> {
    let event = string(input, "hook_event_name").unwrap_or_default();
    match event {
        "SessionStart" => {
            let result = if string(input, "source") == Some("compact") {
                context(input)?
            } else {
                cadence()?
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
            let annotation = annotation(strings(&normalized, "files"));
            let typecheck = typecheck(&normalized)?;
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

fn archive(input: &Value) -> Result<Value, String> {
    let cwd = canonical_cwd(input).map_err(|_| {
        format!(
            "Archive cwd does not exist: {}",
            string(input, "cwd").unwrap_or(".")
        )
    })?;
    let relative_plan = string(input, "plan").unwrap_or_default();
    let plan_path = Path::new(relative_plan);
    if plan_path.parent() != Some(Path::new(".plans")) {
        return Err(format!(
            "Plan must be directly under .plans/: {relative_plan}"
        ));
    }
    let plan_name = plan_path
        .file_name()
        .and_then(|value| value.to_str())
        .unwrap_or_default();
    if !plan_name.starts_with("plan-") || !plan_name.ends_with(".md") {
        return Err(format!("Plan must match .plans/plan-*.md: {relative_plan}"));
    }
    let source_plan = cwd.join(plan_path);
    if !source_plan.is_file() {
        return Err(format!("Plan does not exist: {relative_plan}"));
    }
    let feature = &plan_name[5..plan_name.len() - 3];
    if feature.is_empty() {
        return Err(format!("Plan feature is empty: {relative_plan}"));
    }

    let plan_contents = fs::read_to_string(&source_plan).map_err(|error| error.to_string())?;
    let sources = research_sources(&cwd, feature, &plan_contents)?;
    let plan_destination = cwd.join("docs/plans").join(plan_name);
    ensure_absent(&plan_destination, &format!("docs/plans/{plan_name}"))?;

    let mut research = Vec::new();
    for source in sources {
        let source_path = Path::new(&source);
        let source_name = source_path
            .file_name()
            .and_then(|value| value.to_str())
            .unwrap_or_default();
        if source_path.parent() != Some(Path::new(".research")) {
            return Err(format!(
                "Research source must be directly under .research/: {source}"
            ));
        }
        if !source_name.starts_with("research-") || !source_name.ends_with(".md") {
            return Err(format!("Invalid research source: {source}"));
        }
        let source_absolute = cwd.join(source_path);
        if !source_absolute.is_file() {
            return Err(format!("Declared research source does not exist: {source}"));
        }
        let relative_destination = format!("docs/research/{source_name}");
        let destination = cwd.join(&relative_destination);
        ensure_absent(&destination, &relative_destination)?;
        research.push((source_absolute, destination, relative_destination));
    }

    let item_slugs = strings(input, "item_slugs");
    for slug in &item_slugs {
        if slug.is_empty()
            || !slug
                .bytes()
                .all(|byte| byte.is_ascii_alphanumeric() || b"._-".contains(&byte))
        {
            return Err(format!("Invalid item slug: {slug}"));
        }
    }

    fs::create_dir_all(cwd.join("docs/research")).map_err(|error| error.to_string())?;
    fs::create_dir_all(cwd.join("docs/plans")).map_err(|error| error.to_string())?;
    let mut moved_research = Vec::new();
    let mut moved = Vec::new();
    for (source, destination, relative) in &research {
        if let Err(error) = fs::rename(source, destination) {
            rollback(&moved_research);
            return Err(format!(
                "Failed to move research source: {relative}: {error}"
            ));
        }
        moved_research.push((source.clone(), destination.clone()));
        moved.push(relative.clone());
    }
    if let Err(error) = fs::rename(&source_plan, &plan_destination) {
        rollback(&moved_research);
        return Err(format!("Failed to move plan: {relative_plan}: {error}"));
    }
    moved.push(format!("docs/plans/{plan_name}"));

    for path in [
        cwd.join(".plans/.implementing"),
        cwd.join(format!(".plans/.plan-{feature}.md.prev")),
        cwd.join(format!(".plans/.plan-{feature}.cycle")),
        cwd.join(format!(".plans/.verify-final-{feature}.md")),
    ] {
        remove_if_exists(&path)?;
    }
    for slug in item_slugs {
        for prefix in ["verify", "blocker", "debug"] {
            remove_if_exists(&cwd.join(format!(".plans/.{prefix}-{slug}.md")))?;
        }
    }

    Ok(json!({ "moved": moved }))
}

fn research_sources(cwd: &Path, feature: &str, plan: &str) -> Result<Vec<String>, String> {
    let mut section = None;
    let mut lines = Vec::new();
    for line in plan.lines() {
        if line.trim_end() == "## Research Sources" {
            section = Some(());
            continue;
        }
        if section.is_some() && line.starts_with("## ") {
            break;
        }
        if section.is_some() {
            lines.push(line);
        }
    }
    if section.is_none() {
        let legacy = format!(".research/research-{feature}.md");
        return Ok(cwd
            .join(&legacy)
            .is_file()
            .then_some(legacy)
            .into_iter()
            .collect());
    }

    let sources: Vec<String> = lines
        .iter()
        .flat_map(|line| line.split('`').enumerate())
        .filter(|(index, value)| {
            index % 2 == 1 && value.starts_with(".research/research-") && value.ends_with(".md")
        })
        .map(|(_, value)| value.to_string())
        .collect();
    if sources.is_empty() && !lines.iter().any(|line| line.trim() == "None") {
        return Err("Research Sources must contain exact backticked paths or None".to_string());
    }
    Ok(sources)
}

fn ensure_absent(path: &Path, relative: &str) -> Result<(), String> {
    match fs::symlink_metadata(path) {
        Ok(_) => Err(format!("Archive destination exists: {relative}")),
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(()),
        Err(error) => Err(error.to_string()),
    }
}

fn rollback(moved: &[(PathBuf, PathBuf)]) {
    for (source, destination) in moved.iter().rev() {
        let _ = fs::rename(destination, source);
    }
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
