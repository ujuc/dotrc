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
        Self {
            severity: Severity::Pass,
            section,
            message: message.into(),
        }
    }
    pub fn fail(section: &'static str, message: impl Into<String>) -> Self {
        Self {
            severity: Severity::Fail,
            section,
            message: message.into(),
        }
    }
    pub fn warn(section: &'static str, message: impl Into<String>) -> Self {
        Self {
            severity: Severity::Warn,
            section,
            message: message.into(),
        }
    }
}

#[derive(Debug)]
pub struct ValidationReport {
    pub findings: Vec<Finding>,
    pub skill_dir: PathBuf,
}

impl ValidationReport {
    pub fn errors(&self) -> usize {
        self.findings
            .iter()
            .filter(|f| f.severity == Severity::Fail)
            .count()
    }
    pub fn warnings(&self) -> usize {
        self.findings
            .iter()
            .filter(|f| f.severity == Severity::Warn)
            .count()
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
    RE.get_or_init(|| {
        Regex::new(r"(?:\.{1,2}/|[A-Za-z0-9_-]+/)*references/[A-Za-z0-9_\-./]+").unwrap()
    })
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
        return Ok(ValidationReport {
            findings,
            skill_dir: skill_dir.to_path_buf(),
        });
    }
    findings.push(Finding::pass("Structure", "SKILL.md exists"));

    if skill_dir.join("README.md").is_file()
        && rules::SUBTREE_SKILLS.contains(&folder_name.as_str())
    {
        findings.push(Finding::pass(
            "Structure",
            "README.md kept from upstream subtree",
        ));
    } else if skill_dir.join("README.md").is_file() {
        findings.push(Finding::fail(
            "Structure",
            "README.md found (local rule: skill folders keep no README.md; the Agent Skills spec allows extra files)",
        ));
    } else {
        findings.push(Finding::pass("Structure", "no README.md"));
    }

    // --- Parse frontmatter ---
    let parsed = match frontmatter::parse_from_file(&skill_file) {
        Ok(p) => p,
        Err(e) => {
            findings.push(Finding::fail("Frontmatter", format!("parse error: {e}")));
            return Ok(ValidationReport {
                findings,
                skill_dir: skill_dir.to_path_buf(),
            });
        }
    };
    let fm = &parsed.frontmatter;
    findings.push(Finding::pass(
        "Frontmatter",
        "opening --- delimiter on line 1",
    ));

    validate_name(fm, &folder_name, &mut findings);
    validate_description(fm, &mut findings);
    validate_xml_tags(fm, &mut findings);
    validate_known_keys(fm, &mut findings);
    validate_values(fm, &mut findings);
    validate_agent_context(fm, &mut findings);
    validate_boolean_fields(fm, &mut findings);
    validate_references(skill_dir, &parsed.raw, &mut findings);
    validate_skill_length(parsed.raw.lines().count(), &mut findings);

    Ok(ValidationReport {
        findings,
        skill_dir: skill_dir.to_path_buf(),
    })
}

fn validate_name(fm: &Frontmatter, folder_name: &str, findings: &mut Vec<Finding>) {
    if rules::RESERVED_NAMES.contains(&folder_name.to_ascii_lowercase().as_str()) {
        findings.push(Finding::warn(
            "Frontmatter",
            format!(
                "folder name '{folder_name}' is reserved outside plugins; Claude Code skips it in enterprise, personal and project locations"
            ),
        ));
    }
    match frontmatter::get_str(fm, "name") {
        None => findings.push(Finding::fail(
            "Frontmatter",
            "name field is missing (required)",
        )),
        Some(n) => {
            findings.push(Finding::pass(
                "Frontmatter",
                format!("name field exists: {n}"),
            ));

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
                    format!(
                        "name length is {} chars (max {})",
                        n.len(),
                        rules::NAME_MAX_LEN
                    ),
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

            if rules::RESERVED_NAME_PREFIXES
                .iter()
                .any(|p| n.starts_with(p))
            {
                findings.push(Finding::fail(
                    "Frontmatter",
                    format!("name must not start with reserved prefix: '{n}'"),
                ));
            } else {
                findings.push(Finding::pass(
                    "Frontmatter",
                    "name does not use reserved prefix",
                ));
            }
        }
    }
}

fn validate_description(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let desc = frontmatter::get_str(fm, "description").unwrap_or("");
    let wtu = frontmatter::get_str(fm, "when_to_use").unwrap_or("");
    let combined_len = desc.chars().count() + wtu.chars().count();

    if desc.is_empty() {
        findings.push(Finding::fail(
            "Frontmatter",
            "description field is missing (required)",
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

    let desc_len = desc.chars().count();
    if desc_len > rules::DESCRIPTION_SPEC_MAX {
        findings.push(Finding::warn(
            "Frontmatter",
            format!(
                "description is {desc_len} chars; the Agent Skills spec allows {} (Claude Code accepts more)",
                rules::DESCRIPTION_SPEC_MAX
            ),
        ));
    }
}

fn validate_xml_tags(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    // Only the listing fields: `argument-hint: <branch>` and hook commands are valid upstream.
    let hit = ["description", "when_to_use"]
        .iter()
        .filter_map(|k| frontmatter::get_str(fm, k))
        .any(|s| xml_re().is_match(s));
    if hit {
        findings.push(Finding::fail(
            "Frontmatter",
            "XML tags found in description/when_to_use",
        ));
    } else {
        findings.push(Finding::pass(
            "Frontmatter",
            "no XML tags in description/when_to_use",
        ));
    }
}

fn validate_known_keys(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let unknown: Vec<&str> = frontmatter::keys(fm)
        .filter(|k| !rules::ALLOWED_KEYS.contains(k))
        .collect();
    if unknown.is_empty() {
        findings.push(Finding::pass(
            "Frontmatter",
            "all frontmatter keys are allowed",
        ));
    } else {
        findings.push(Finding::warn(
            "Frontmatter",
            format!("unknown frontmatter key(s): {}", unknown.join(", ")),
        ));
    }
}

fn validate_values(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    validate_model(fm, findings);
    check_enum(fm, "effort", rules::ALLOWED_EFFORTS, findings);
    check_enum(fm, "context", rules::ALLOWED_CONTEXTS, findings);
    check_enum(fm, "shell", rules::ALLOWED_SHELLS, findings);
    for key in rules::STRING_OR_LIST_KEYS {
        check_string_or_list(fm, key, findings);
    }
    validate_metadata(fm, findings);
    validate_compatibility(fm, findings);
}

fn check_string_or_list(fm: &Frontmatter, key: &str, findings: &mut Vec<Finding>) {
    let Some(v) = frontmatter::get_value(fm, key) else {
        return;
    };
    let ok = match v {
        Value::String(s) => !s.trim().is_empty(),
        Value::Sequence(items) => items.iter().all(Value::is_string),
        _ => false,
    };
    if ok {
        findings.push(Finding::pass("Values", format!("{key} format is valid")));
    } else {
        findings.push(Finding::fail(
            "Values",
            format!("{key} must be a non-empty string or a list of strings"),
        ));
    }
}

fn validate_metadata(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let Some(v) = frontmatter::get_value(fm, "metadata") else {
        return;
    };
    let Value::Mapping(map) = v else {
        findings.push(Finding::fail(
            "Values",
            "metadata must be a map; Claude Code drops other values",
        ));
        return;
    };
    let mut clean = true;
    for (k, val) in map {
        if let Some(key) = k.as_str().filter(|key| rules::ALLOWED_KEYS.contains(key)) {
            clean = false;
            findings.push(Finding::warn(
                "Values",
                format!("metadata key '{key}' reuses a frontmatter field name"),
            ));
        }
        if !(k.is_string() && val.is_string()) {
            clean = false;
            findings.push(Finding::warn(
                "Values",
                format!("metadata entry {k:?} must map a string key to a string value (quote scalars such as version: \"1.0\")"),
            ));
        }
    }
    if clean {
        findings.push(Finding::pass("Values", "metadata is a flat map of strings"));
    }
}

fn validate_compatibility(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let Some(v) = frontmatter::get_value(fm, "compatibility") else {
        return;
    };
    let len = v.as_str().map(|s| s.chars().count());
    if len.is_some_and(|n| (1..=rules::COMPATIBILITY_MAX).contains(&n)) {
        findings.push(Finding::pass("Values", "compatibility length is valid"));
    } else {
        findings.push(Finding::fail(
            "Values",
            format!(
                "compatibility must be a string of 1-{} characters",
                rules::COMPATIBILITY_MAX
            ),
        ));
    }
}

fn validate_model(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    let Some(value) = frontmatter::get_value(fm, "model") else {
        return;
    };
    match value.as_str() {
        Some(model) if !model.trim().is_empty() => findings.push(Finding::pass(
            "Values",
            "model is a non-empty string (host availability is not checked)",
        )),
        _ => findings.push(Finding::fail(
            "Values",
            "model must be a non-empty string; omit it to inherit the host/session default",
        )),
    }
}

fn check_enum(fm: &Frontmatter, key: &str, allowed: &[&str], findings: &mut Vec<Finding>) {
    let Some(raw) = frontmatter::get_value(fm, key) else {
        return;
    };
    let Some(value) = raw.as_str() else {
        findings.push(Finding::fail(
            "Values",
            format!("{key} must be one of {:?}", allowed),
        ));
        return;
    };
    if allowed.contains(&value) {
        findings.push(Finding::pass(
            "Values",
            format!("{key} value '{value}' is valid"),
        ));
    } else {
        findings.push(Finding::fail(
            "Values",
            format!("{key} must be one of {:?}, got '{value}'", allowed),
        ));
    }
}

fn validate_agent_context(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    if frontmatter::get_value(fm, "background").is_some()
        && frontmatter::get_str(fm, "context") != Some("fork")
    {
        findings.push(Finding::warn(
            "Values",
            "background is set but context is not 'fork'; Claude Code ignores it",
        ));
    }
    if frontmatter::get_value(fm, "agent").is_none() {
        return;
    }
    match frontmatter::get_str(fm, "context") {
        Some("fork") => {
            findings.push(Finding::pass(
                "Values",
                "agent is paired with context: fork",
            ));
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

fn validate_boolean_fields(fm: &Frontmatter, findings: &mut Vec<Finding>) {
    for key in rules::BOOLEAN_KEYS {
        let Some(v) = frontmatter::get_value(fm, key) else {
            continue;
        };
        let loose = match v {
            Value::Bool(_) => {
                findings.push(Finding::pass("Values", format!("{key} is a boolean")));
                continue;
            }
            Value::Number(n) => n.as_u64().is_some_and(|n| n <= 1),
            Value::String(s) => {
                rules::LOOSE_BOOLEAN_WORDS.contains(&s.to_ascii_lowercase().as_str())
            }
            _ => false,
        };
        if loose {
            findings.push(Finding::warn(
                "Values",
                format!("{key} uses a form Claude Code also reads as a boolean; write true/false for portability"),
            ));
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
        let lead = raw[..m.start()]
            .rsplit(char::is_whitespace)
            .next()
            .unwrap_or("");
        if rules::NON_SKILL_PATH_VARS.iter().any(|v| lead.contains(v)) {
            continue;
        }
        let p = m.as_str().trim_end_matches(['.', ',', ')']);
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

fn validate_skill_length(lines: usize, findings: &mut Vec<Finding>) {
    let max = rules::SKILL_LINE_WARN_THRESHOLD;
    if lines < max {
        findings.push(Finding::pass(
            "Content",
            format!("SKILL.md is {lines} lines (keep under {max})"),
        ));
    } else {
        findings.push(Finding::warn(
            "Content",
            format!("SKILL.md is {lines} lines (keep under {max}) — consider moving content to references/"),
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
    fn reference_paths_preserve_relative_prefixes() {
        let source = "`references/local.md` [guide](../peer/references/shared.md) \
                      `../../shared/references/deep.md` `./references/local.md`";
        let paths: Vec<_> = ref_path_re()
            .find_iter(source)
            .map(|m| m.as_str())
            .collect();
        assert_eq!(
            paths,
            [
                "references/local.md",
                "../peer/references/shared.md",
                "../../shared/references/deep.md",
                "./references/local.md"
            ]
        );
    }

    #[test]
    fn references_resolve_sibling_paths_without_local_fallback() {
        let unique = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "skill-reference-test-{}-{unique}",
            std::process::id()
        ));
        let skill = root.join("subject");
        std::fs::create_dir_all(skill.join("references")).unwrap();
        std::fs::create_dir_all(root.join("peer/references")).unwrap();
        std::fs::write(skill.join("references/local.md"), "local").unwrap();
        std::fs::write(skill.join("references/missing.md"), "decoy").unwrap();
        std::fs::write(root.join("peer/references/shared.md"), "shared").unwrap();

        let mut findings = Vec::new();
        validate_references(
            &skill,
            "`references/local.md` [shared](../peer/references/shared.md)",
            &mut findings,
        );
        assert_eq!(findings.len(), 1);
        assert_eq!(findings[0].severity, Severity::Pass);

        findings.clear();
        validate_references(&skill, "`../peer/references/missing.md`", &mut findings);
        assert_eq!(findings.len(), 1);
        assert_eq!(findings[0].severity, Severity::Fail);
        assert_eq!(
            findings[0].message,
            "broken path: ../peer/references/missing.md"
        );
        std::fs::remove_dir_all(root).unwrap();
    }

    #[test]
    fn enum_check_accepts_valid() {
        let fm = fm_from("---\nname: t\ncontext: fork\n---\n");
        let mut findings = Vec::new();
        check_enum(&fm, "context", rules::ALLOWED_CONTEXTS, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Pass));
    }

    #[test]
    fn enum_check_rejects_invalid() {
        let fm = fm_from("---\nname: t\ncontext: unknown\n---\n");
        let mut findings = Vec::new();
        check_enum(&fm, "context", rules::ALLOWED_CONTEXTS, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn enum_check_skips_missing() {
        let fm = fm_from("---\nname: t\n---\n");
        let mut findings = Vec::new();
        check_enum(&fm, "context", rules::ALLOWED_CONTEXTS, &mut findings);
        assert!(findings.is_empty());
    }

    #[test]
    fn model_accepts_identifiers_without_provider_allowlist() {
        for model in [
            "inherit",
            "opus",
            "provider/custom-model",
            "local-model:latest",
        ] {
            let fm = fm_from(&format!("---\nmodel: {model}\n---\n"));
            let mut findings = Vec::new();
            validate_values(&fm, &mut findings);
            assert_eq!(findings.len(), 1, "model: {model}");
            assert_eq!(findings[0].severity, Severity::Pass, "model: {model}");
            assert!(
                findings[0]
                    .message
                    .contains("host availability is not checked")
            );
        }
    }

    #[test]
    fn model_rejects_empty_and_non_string_values() {
        for model in ["", "null", "''", "'   '", "true", "42", "[]", "{}"] {
            let fm = fm_from(&format!("---\nmodel: {model}\n---\n"));
            let mut findings = Vec::new();
            validate_values(&fm, &mut findings);
            assert_eq!(findings.len(), 1, "model: {model}");
            assert_eq!(findings[0].severity, Severity::Fail, "model: {model}");
        }
    }

    #[test]
    fn model_omission_inherits_without_finding() {
        let fm = fm_from("---\nname: t\n---\n");
        let mut findings = Vec::new();
        validate_model(&fm, &mut findings);
        assert!(findings.is_empty());
    }

    #[test]
    fn missing_required_name_fails() {
        let fm = fm_from("---\ndescription: test\n---\n");
        let mut findings = Vec::new();
        validate_name(&fm, "test", &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn missing_required_description_fails() {
        let fm = fm_from("---\nname: test\n---\n");
        let mut findings = Vec::new();
        validate_description(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
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
        check_string_or_list(&fm, "allowed-tools", &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_comma_no_space_passes() {
        let fm = fm_from("---\nname: t\nallowed-tools: \"Read,Grep,Glob\"\n---\n");
        let mut findings = Vec::new();
        check_string_or_list(&fm, "allowed-tools", &mut findings);
        assert!(findings.iter().all(|f| f.severity == Severity::Pass));
    }

    #[test]
    fn allowed_tools_space_separated_passes() {
        let fm = fm_from("---\nname: t\nallowed-tools: \"Read Grep Glob\"\n---\n");
        let mut findings = Vec::new();
        check_string_or_list(&fm, "allowed-tools", &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_list_passes() {
        let src = "---\nname: t\nallowed-tools:\n  - Read\n  - Grep\n---\n";
        let fm = fm_from(src);
        let mut findings = Vec::new();
        check_string_or_list(&fm, "allowed-tools", &mut findings);
        assert!(findings.iter().all(|f| f.severity != Severity::Fail));
    }

    #[test]
    fn allowed_tools_empty_string_fails() {
        let fm = fm_from("---\nname: t\nallowed-tools: \"\"\n---\n");
        let mut findings = Vec::new();
        check_string_or_list(&fm, "allowed-tools", &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Fail));
    }

    #[test]
    fn loose_boolean_forms_warn_and_others_fail() {
        let sev = |src: &str| {
            let mut findings = Vec::new();
            validate_boolean_fields(&fm_from(src), &mut findings);
            findings[0].severity
        };
        assert_eq!(
            sev("---\ndisable-model-invocation: \"yes\"\n---\n"),
            Severity::Warn
        );
        assert_eq!(sev("---\nbackground: 1\n---\n"), Severity::Warn);
        assert_eq!(sev("---\nbackground: false\n---\n"), Severity::Pass);
        assert_eq!(sev("---\nuser-invocable: maybe\n---\n"), Severity::Fail);
        assert_eq!(sev("---\nbackground: 2\n---\n"), Severity::Fail);
    }

    fn severities(run: fn(&Frontmatter, &mut Vec<Finding>), src: &str) -> Vec<Severity> {
        let mut findings = Vec::new();
        run(&fm_from(src), &mut findings);
        findings.iter().map(|f| f.severity).collect()
    }

    #[test]
    fn xml_check_covers_listing_fields_only() {
        let hint = "---\ndescription: plain\nargument-hint: <branch>\n---\n";
        assert_eq!(severities(validate_xml_tags, hint), [Severity::Pass]);
        let desc = "---\ndescription: use <b>bold</b>\n---\n";
        assert_eq!(severities(validate_xml_tags, desc), [Severity::Fail]);
    }

    #[test]
    fn value_types_are_checked() {
        let fails = |src: &str| severities(validate_values, src).contains(&Severity::Fail);
        assert!(fails("---\neffort: 3\n---\n"));
        assert!(fails("---\ndisallowed-tools: 5\n---\n"));
        assert!(fails("---\npaths: true\n---\n"));
        assert!(fails("---\narguments:\n  a: 1\n---\n"));
        assert!(fails("---\nmetadata: text\n---\n"));
        assert!(fails("---\ncompatibility: \"\"\n---\n"));
        assert!(fails(&format!(
            "---\ncompatibility: {}\n---\n",
            "x".repeat(501)
        )));
        assert!(!fails(
            "---\npaths: \"src/**\"\narguments: [a, b]\nmetadata:\n  version: \"1.0\"\ncompatibility: needs git\n---\n"
        ));
    }

    #[test]
    fn metadata_non_string_value_or_field_name_key_warns() {
        let warns = |src: &str| severities(validate_metadata, src) == [Severity::Warn];
        assert!(warns("---\nmetadata:\n  version: 1.0\n---\n"));
        assert!(warns("---\nmetadata:\n  paths: x\n---\n"));
    }

    #[test]
    fn description_over_spec_cap_warns_without_failing() {
        let src = format!("---\ndescription: {}\n---\n", "x".repeat(1100));
        let got = severities(validate_description, &src);
        assert!(got.contains(&Severity::Warn) && !got.contains(&Severity::Fail));
    }

    #[test]
    fn background_without_fork_warns() {
        let got = severities(validate_agent_context, "---\nbackground: false\n---\n");
        assert_eq!(got, [Severity::Warn]);
    }

    #[test]
    fn reserved_folder_name_warns() {
        let mut findings = Vec::new();
        validate_name(
            &fm_from("---\nname: synced\n---\n"),
            "Synced",
            &mut findings,
        );
        assert_eq!(findings[0].severity, Severity::Warn);
    }

    #[test]
    fn references_behind_plugin_root_are_not_resolved() {
        let mut findings = Vec::new();
        let raw = "see `${CLAUDE_PLUGIN_ROOT}/skills/peer/references/shared.md`";
        validate_references(Path::new("/nonexistent"), raw, &mut findings);
        assert!(findings.is_empty());
    }

    #[test]
    fn skill_length_warns_at_threshold() {
        let sev = |n| {
            let mut findings = Vec::new();
            validate_skill_length(n, &mut findings);
            findings[0].severity
        };
        assert_eq!(sev(499), Severity::Pass);
        assert_eq!(sev(500), Severity::Warn);
    }

    #[test]
    fn unknown_keys_warn() {
        let fm = fm_from("---\nname: t\nsomething-new: 1\n---\n");
        let mut findings = Vec::new();
        validate_known_keys(&fm, &mut findings);
        assert!(findings.iter().any(|f| f.severity == Severity::Warn));
    }
}
