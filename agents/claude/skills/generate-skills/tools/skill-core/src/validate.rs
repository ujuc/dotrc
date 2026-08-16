use crate::frontmatter::{self, Frontmatter};
use crate::rules;
use regex::Regex;
use serde_yaml::Value;
use std::collections::HashSet;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Severity {
    Pass,
    Warn,
    Fail,
}

#[derive(Debug, Clone)]
pub struct Finding {
    pub severity: Severity,
    pub section: &'static str,
    pub message: String,
}

impl Finding {
    pub fn pass(section: &'static str, message: impl Into<String>) -> Self {
        Self { severity: Severity::Pass, section, message: message.into() }
    }
    pub fn fail(section: &'static str, message: impl Into<String>) -> Self {
        Self { severity: Severity::Fail, section, message: message.into() }
    }
    pub fn warn(section: &'static str, message: impl Into<String>) -> Self {
        Self { severity: Severity::Warn, section, message: message.into() }
    }
}

#[derive(Debug)]
pub struct ValidationReport {
    pub findings: Vec<Finding>,
    pub skill_dir: PathBuf,
}

impl ValidationReport {
    pub fn errors(&self) -> usize {
        self.findings.iter().filter(|f| f.severity == Severity::Fail).count()
    }
    pub fn warnings(&self) -> usize {
        self.findings.iter().filter(|f| f.severity == Severity::Warn).count()
    }
    pub fn has_errors(&self) -> bool {
        self.errors() > 0
    }
}

fn xml_re() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r"<[a-zA-Z][a-zA-Z0-9]*[^>]*>").unwrap())
}

fn ref_path_re() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r"references/[A-Za-z0-9_\-./]+").unwrap())
}

pub fn validate_skill(skill_dir: &Path) -> anyhow::Result<ValidationReport> {
    let mut findings = Vec::new();
    let folder_name = skill_dir
        .file_name()
        .and_then(|s| s.to_str())
        .unwrap_or("")
        .to_string();

    let skill_file = skill_dir.join("SKILL.md");

    // --- Structure ---
    if !skill_file.is_file() {
        findings.push(Finding::fail(
            "Structure",
            format!("SKILL.md not found ({})", skill_file.display()),
        ));
        return Ok(ValidationReport { findings, skill_dir: skill_dir.to_path_buf() });
    }
    findings.push(Finding::pass("Structure", "SKILL.md exists"));

    if skill_dir.join("README.md").is_file() {
        findings.push(Finding::fail(
            "Structure",
            "README.md found (skill folders must not contain README.md)",
        ));
    } else {
        findings.push(Finding::pass("Structure", "no README.md"));
    }

    // --- Parse frontmatter ---
    let parsed = match frontmatter::parse_from_file(&skill_file) {
        Ok(p) => p,
        Err(e) => {
            findings.push(Finding::fail("Frontmatter", format!("parse error: {e}")));
            return Ok(ValidationReport { findings, skill_dir: skill_dir.to_path_buf() });
        }
    };
    let fm = &parsed.frontmatter;
    findings.push(Finding::pass("Frontmatter", "opening --- delimiter on line 1"));

    validate_name(fm, &folder_name, &mut findings);
    validate_description(fm, &mut findings);
    validate_xml_tags(fm, &mut findings);
    validate_known_keys(fm, &mut findings);
    validate_values(fm, &mut findings);
    validate_group(fm, &mut findings);
    validate_agent_context(fm, &mut findings);
    validate_allowed_tools(fm, &mut findings);
    validate_boolean_fields(fm, &mut findings);
    validate_references(skill_dir, &parsed.raw, &mut findings);
    validate_body_length(parsed.body_lines, &mut findings);

    Ok(ValidationReport { findings, skill_dir: skill_dir.to_path_buf() })
}

fn validate_name(fm: &Frontmatter, folder_name: &str, findings: &mut Vec<Finding>) {
    match frontmatter::get_str(fm, "name") {
        None => findings.push(Finding::warn(
            "Frontmatter",
            "name field is missing (optional; directory name will be used)",
        )),
        Some(n) => {
            findings.push(Finding::pass("Frontmatter", format!("name field exists: {n}")));

            if rules::is_kebab_case(n) {
                findings.push(Finding::pass("Frontmatter", "name is kebab-case"));
            } else {
                findings.push(Finding::fail(
                    "Frontmatter",
                    format!("name is not kebab-case: '{n}'"),
                ));
            }

            if n.len() <= rules::NAME_MAX_LEN {
                findings.push(Finding::pass(
                    "Frontmatter",
                    format!("name length is {} chars (max {})", n.len(), rules::NAME_MAX_LEN),
                ));
            } else {
                findings.push(Finding::fail(
                    "Frontmatter",
                    format!(
                        "name exceeds {} chars: '{n}' ({} chars)",
                        rules::NAME_MAX_LEN,
                        n.len()
                    ),
                ));
            }

            if n == folder_name {
                findings.push(Finding::pass("Frontmatter", "name matches folder name"));
            } else {
                findings.push(Finding::fail(
                    "Frontmatter",
                    format!("name '{n}' does not match folder name '{folder_name}'"),
                ));
            }

            if rules::RESERVED_NAME_PREFIXES.iter().any(|p| n.starts_with(p)) {
                findings.push(Finding::fail(
                    "Frontmatter",
                    format!("name must not start with reserved prefix: '{n}'"),
                ));
            } else {
                findings.push(Finding::pass("Frontmatter", "name does not use reserved prefix"));
            }
        }
    }
}

fn validate_description(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let desc = frontmatter::get_str(fm, "description").unwrap_or("");
    let wtu = frontmatter::get_str(fm, "when_to_use").unwrap_or("");
    let combined_len = desc.chars().count() + wtu.chars().count();

    if desc.is_empty() {
        findings.push(Finding::warn(
            "Frontmatter",
            "description field is missing (recommended for trigger accuracy)",
        ));
        return;
    }

    if combined_len <= rules::DESCRIPTION_COMBINED_MAX {
        findings.push(Finding::pass(
            "Frontmatter",
            format!(
                "description + when_to_use length is {combined_len} chars (max {})",
                rules::DESCRIPTION_COMBINED_MAX
            ),
        ));
    } else {
        findings.push(Finding::fail(
            "Frontmatter",
            format!(
                "description + when_to_use exceeds {} chars ({combined_len} chars)",
                rules::DESCRIPTION_COMBINED_MAX
            ),
        ));
    }
}

fn validate_xml_tags(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let Ok(serialized) = serde_yaml::to_string(&Value::Mapping(fm.clone())) else {
        return;
    };
    if xml_re().is_match(&serialized) {
        findings.push(Finding::fail("Frontmatter", "XML tags found in frontmatter"));
    } else {
        findings.push(Finding::pass("Frontmatter", "no XML tags in frontmatter"));
    }
}

fn validate_known_keys(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let unknown: Vec<&str> = frontmatter::keys(fm)
        .filter(|k| !rules::ALLOWED_KEYS.contains(k))
        .collect();
    if unknown.is_empty() {
        findings.push(Finding::pass("Frontmatter", "all frontmatter keys are allowed"));
    } else {
        findings.push(Finding::warn(
            "Frontmatter",
            format!("unknown frontmatter key(s): {}", unknown.join(", ")),
        ));
    }
}

fn validate_values(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    check_enum(fm, "model", rules::ALLOWED_MODELS, findings);
    check_enum(fm, "effort", rules::ALLOWED_EFFORTS, findings);
    check_enum(fm, "context", rules::ALLOWED_CONTEXTS, findings);
    check_enum(fm, "shell", rules::ALLOWED_SHELLS, findings);
}

fn check_enum(fm: &Frontmatter, key: &str, allowed: &[&str], findings: &mut Vec<Finding>) {
    let Some(value) = frontmatter::get_str(fm, key) else {
        return;
    };
    if allowed.contains(&value) {
        findings.push(Finding::pass("Values", format!("{key} value '{value}' is valid")));
    } else {
        findings.push(Finding::fail(
            "Values",
            format!("{key} must be one of {:?}, got '{value}'", allowed),
        ));
    }
}

fn validate_group(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    match frontmatter::get_str(fm, "group") {
        None => findings.push(Finding::fail(
            "Frontmatter",
            format!(
                "group field is missing (local extension; required for /skills catalog). Set to one of: {:?}",
                rules::ALLOWED_GROUPS
            ),
        )),
        Some(g) => {
            if rules::ALLOWED_GROUPS.contains(&g) {
                findings.push(Finding::pass(
                    "Frontmatter",
                    format!("group value '{g}' is valid"),
                ));
            } else {
                findings.push(Finding::fail(
                    "Frontmatter",
                    format!(
                        "group must be one of {:?}, got '{g}'",
                        rules::ALLOWED_GROUPS
                    ),
                ));
            }
        }
    }
}

fn validate_agent_context(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    if frontmatter::get_value(fm, "agent").is_none() {
        return;
    }
    match frontmatter::get_str(fm, "context") {
        Some("fork") => {
            findings.push(Finding::pass("Values", "agent is paired with context: fork"));
        }
        Some(other) => findings.push(Finding::fail(
            "Values",
            format!("agent is set but context is '{other}' (must be 'fork')"),
        )),
        None => findings.push(Finding::fail(
            "Values",
            "agent is set but context is missing (must be 'fork')",
        )),
    }
}

fn validate_allowed_tools(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let Some(v) = frontmatter::get_value(fm, "allowed-tools") else {
        return;
    };
    match v {
        Value::String(s) => {
            if s.trim().is_empty() {
                findings.push(Finding::fail("Values", "allowed-tools string is empty"));
            } else if s.contains(',') && !s.contains(' ') {
                findings.push(Finding::warn(
                    "Values",
                    "allowed-tools has commas without spaces — ensure separator is consistent",
                ));
            } else {
                findings.push(Finding::pass("Values", "allowed-tools format is valid"));
            }
        }
        Value::Sequence(_) => {
            findings.push(Finding::pass("Values", "allowed-tools format is valid (list)"));
        }
        _ => findings.push(Finding::fail(
            "Values",
            "allowed-tools must be a string or list",
        )),
    }
}

fn validate_boolean_fields(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    for key in ["disable-model-invocation", "user-invocable"] {
        let Some(v) = frontmatter::get_value(fm, key) else {
            continue;
        };
        if matches!(v, Value::Bool(_)) {
            findings.push(Finding::pass("Values", format!("{key} is a boolean")));
        } else {
            findings.push(Finding::fail(
                "Values",
                format!("{key} must be a boolean (true/false)"),
            ));
        }
    }
}

fn validate_references(skill_dir: &Path, raw: &str, findings: &mut Vec<Finding>) {
    let mut seen: HashSet<String> = HashSet::new();
    let mut broken: Vec<String> = Vec::new();

    for m in ref_path_re().find_iter(raw) {
        let p = m.as_str().trim_end_matches(|c: char| c == '.' || c == ',' || c == ')');
        if !seen.insert(p.to_string()) {
            continue;
        }
        if !skill_dir.join(p).exists() {
            broken.push(p.to_string());
        }
    }

    if seen.is_empty() {
        return;
    }
    if broken.is_empty() {
        findings.push(Finding::pass(
            "References",
            format!("all {} references/ paths resolve", seen.len()),
        ));
    } else {
        for b in &broken {
            findings.push(Finding::fail("References", format!("broken path: {b}")));
        }
    }
}

fn validate_body_length(body_lines: usize, findings: &mut Vec<Finding>) {
    if body_lines <= rules::BODY_LINE_WARN_THRESHOLD {
        findings.push(Finding::pass(
            "Content",
            format!(
                "SKILL.md body is {body_lines} lines (max {})",
                rules::BODY_LINE_WARN_THRESHOLD
            ),
        ));
    } else {
        findings.push(Finding::warn(
            "Content",
            format!(
                "SKILL.md body exceeds {} lines ({body_lines} lines) — consider moving content to references/",
                rules::BODY_LINE_WARN_THRESHOLD
            ),
        ));
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::frontmatter::parse_from_str;

    fn fm_from(src: &str) -> Frontmatter {
        parse_from_str(src).unwrap().frontmatter
    }

    #[test]
    fn enum_check_accepts_valid() {
        let fm = fm_from("---\nname: t\nmodel: opus\n---\n");
        let mut findings = Vec::new();
        check_enum(&fm, "model", rules::ALLOWED_MODELS, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Pass));
    }

    #[test]
    fn enum_check_rejects_invalid() {
        let fm = fm_from("---\nname: t\nmodel: gpt-4\n---\n");
        let mut findings = Vec::new();
        check_enum(&fm, "model", rules::ALLOWED_MODELS, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn enum_check_skips_missing() {
        let fm = fm_from("---\nname: t\n---\n");
        let mut findings = Vec::new();
        check_enum(&fm, "model", rules::ALLOWED_MODELS, &mut findings);
        assert!(findings.is_empty());
    }

    #[test]
    fn description_length_combined() {
        let long_desc = "x".repeat(1000);
        let long_wtu = "y".repeat(600);
        let src = format!(
            "---\nname: t\ndescription: {}\nwhen_to_use: {}\n---\n",
            long_desc, long_wtu
        );
        let fm = fm_from(&src);
        let mut findings = Vec::new();
        validate_description(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn description_length_ok() {
        let desc = "x".repeat(800);
        let wtu = "y".repeat(600);
        let src = format!(
            "---\nname: t\ndescription: {}\nwhen_to_use: {}\n---\n",
            desc, wtu
        );
        let fm = fm_from(&src);
        let mut findings = Vec::new();
        validate_description(&fm, &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn agent_without_fork_fails() {
        let fm = fm_from("---\nname: t\nagent: Explore\n---\n");
        let mut findings = Vec::new();
        validate_agent_context(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn agent_with_fork_passes() {
        let fm = fm_from("---\nname: t\nagent: Explore\ncontext: fork\n---\n");
        let mut findings = Vec::new();
        validate_agent_context(&fm, &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_comma_with_spaces_passes() {
        // comma-separated with spaces is the de-facto convention across all skills.
        let fm = fm_from("---\nname: t\nallowed-tools: \"Read, Grep, Glob\"\n---\n");
        let mut findings = Vec::new();
        validate_allowed_tools(&fm, &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_comma_no_space_warns() {
        let fm = fm_from("---\nname: t\nallowed-tools: \"Read,Grep,Glob\"\n---\n");
        let mut findings = Vec::new();
        validate_allowed_tools(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Warn));
    }

    #[test]
    fn allowed_tools_space_separated_passes() {
        let fm = fm_from("---\nname: t\nallowed-tools: \"Read Grep Glob\"\n---\n");
        let mut findings = Vec::new();
        validate_allowed_tools(&fm, &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_list_passes() {
        let src = "---\nname: t\nallowed-tools:\n  - Read\n  - Grep\n---\n";
        let fm = fm_from(src);
        let mut findings = Vec::new();
        validate_allowed_tools(&fm, &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_empty_string_fails() {
        let fm = fm_from("---\nname: t\nallowed-tools: \"\"\n---\n");
        let mut findings = Vec::new();
        validate_allowed_tools(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn non_boolean_disable_invocation_fails() {
        let fm = fm_from("---\nname: t\ndisable-model-invocation: \"yes\"\n---\n");
        let mut findings = Vec::new();
        validate_boolean_fields(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn unknown_keys_warn() {
        let fm = fm_from("---\nname: t\nsomething-new: 1\n---\n");
        let mut findings = Vec::new();
        validate_known_keys(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Warn));
    }

    #[test]
    fn group_is_in_allowed_keys() {
        let fm = fm_from("---\nname: t\ngroup: planning\n---\n");
        let mut findings = Vec::new();
        validate_known_keys(&fm, &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Warn));
    }

    #[test]
    fn missing_group_fails() {
        let fm = fm_from("---\nname: t\n---\n");
        let mut findings = Vec::new();
        validate_group(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn invalid_group_fails() {
        let fm = fm_from("---\nname: t\ngroup: foobar\n---\n");
        let mut findings = Vec::new();
        validate_group(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn valid_group_passes() {
        let fm = fm_from("---\nname: t\ngroup: planning\n---\n");
        let mut findings = Vec::new();
        validate_group(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Pass));
    }
}
