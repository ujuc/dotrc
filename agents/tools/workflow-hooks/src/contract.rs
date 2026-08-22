use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::path::{Component, Path};

const CONTRACT_JSON: &str = include_str!("../../../workflow-contract.json");

const REQUIRED_ARTIFACTS: &[&str] = &[
    "spec",
    "contract",
    "research",
    "plan",
    "qa_report",
    "design_report",
    "evaluation_report",
    "handoff",
];
const REQUIRED_TRANSIENT: &[&str] = &[
    "implementation_flag",
    "verification_pattern",
    "blocker_pattern",
    "debug_pattern",
    "plan_baseline_pattern",
    "plan_cycle_pattern",
];
const REQUIRED_ARCHIVE: &[&str] = &[
    "spec",
    "contract",
    "research_directory",
    "plan_directory",
    "evaluation_report",
];

#[derive(Debug, Deserialize, Serialize)]
pub struct WorkflowContract {
    pub schema_version: u64,
    pub contract_version: String,
    pub workflow: WorkflowPolicy,
    pub artifacts: BTreeMap<String, Artifact>,
    pub transient: BTreeMap<String, String>,
    pub archive: BTreeMap<String, String>,
    pub maintenance: Maintenance,
    pub superpowers: Superpowers,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct WorkflowPolicy {
    pub single_active: bool,
    pub plan_writer: String,
    pub execution_engine: String,
    pub git_policy: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Artifact {
    pub path: Option<String>,
    pub pattern: Option<String>,
    pub writer: String,
    pub context: bool,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Maintenance {
    pub skill_improver: SkillImproverMaintenance,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct SkillImproverMaintenance {
    pub interval_days: i64,
    pub timestamp: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Superpowers {
    pub adapted_from: BTreeMap<String, String>,
    pub optional_disciplines: Vec<String>,
    pub excluded_workflow_skills: Vec<String>,
}

pub fn load() -> Result<WorkflowContract, String> {
    parse(CONTRACT_JSON)
}

pub fn parse(contents: &str) -> Result<WorkflowContract, String> {
    let contract: WorkflowContract = serde_json::from_str(contents)
        .map_err(|error| format!("invalid workflow contract: {error}"))?;
    contract.validate()?;
    Ok(contract)
}

impl WorkflowContract {
    pub fn artifact(&self, name: &str) -> Result<&Artifact, String> {
        self.artifacts
            .get(name)
            .ok_or_else(|| format!("workflow contract missing artifact: {name}"))
    }

    pub fn transient(&self, name: &str) -> Result<&str, String> {
        self.transient
            .get(name)
            .map(String::as_str)
            .ok_or_else(|| format!("workflow contract missing transient path: {name}"))
    }

    pub fn archive(&self, name: &str) -> Result<&str, String> {
        self.archive
            .get(name)
            .map(String::as_str)
            .ok_or_else(|| format!("workflow contract missing archive path: {name}"))
    }

    pub fn matches_artifact(&self, name: &str, value: &str) -> bool {
        self.artifact(name)
            .ok()
            .and_then(Artifact::template)
            .is_some_and(|template| template_matches(template, value))
    }

    pub fn render_archive(&self, name: &str, feature: &str) -> Result<String, String> {
        if feature.is_empty()
            || !feature
                .bytes()
                .all(|byte| byte.is_ascii_alphanumeric() || b"._-".contains(&byte))
        {
            return Err(format!("invalid archive feature: {feature}"));
        }
        let rendered = self.archive(name)?.replace("{feature}", feature);
        if rendered.contains('{') || rendered.contains('}') || rendered.contains('*') {
            return Err(format!("archive template requires more values: {rendered}"));
        }
        Ok(rendered)
    }

    fn validate(&self) -> Result<(), String> {
        if self.schema_version != 1 {
            return Err(format!(
                "unsupported workflow contract schema: {}",
                self.schema_version
            ));
        }
        require_text("contract_version", &self.contract_version)?;
        if !self.workflow.single_active {
            return Err("workflow.single_active must be true".to_string());
        }
        require_text("workflow.plan_writer", &self.workflow.plan_writer)?;
        require_text("workflow.execution_engine", &self.workflow.execution_engine)?;
        require_text("workflow.git_policy", &self.workflow.git_policy)?;

        require_keys("artifact", REQUIRED_ARTIFACTS, &self.artifacts)?;
        for (name, artifact) in &self.artifacts {
            require_text(&format!("artifacts.{name}.writer"), &artifact.writer)?;
            let template = match (&artifact.path, &artifact.pattern) {
                (Some(path), None) | (None, Some(path)) => path,
                _ => {
                    return Err(format!(
                        "artifacts.{name} must define exactly one of path or pattern"
                    ));
                }
            };
            validate_relative(&format!("artifacts.{name}"), template)?;
            validate_tokens(&format!("artifacts.{name}"), template)?;
        }

        require_keys("transient path", REQUIRED_TRANSIENT, &self.transient)?;
        for (name, path) in &self.transient {
            validate_relative(&format!("transient.{name}"), path)?;
            validate_tokens(&format!("transient.{name}"), path)?;
        }

        require_keys("archive path", REQUIRED_ARCHIVE, &self.archive)?;
        for (name, path) in &self.archive {
            validate_relative(&format!("archive.{name}"), path)?;
            validate_tokens(&format!("archive.{name}"), path)?;
        }

        if self.maintenance.skill_improver.interval_days < 1 {
            return Err("maintenance.skill_improver.interval_days must be positive".to_string());
        }
        let timestamp = &self.maintenance.skill_improver.timestamp;
        let timestamp_relative = timestamp.strip_prefix("~/").unwrap_or_default();
        if timestamp_relative.is_empty()
            || Path::new(timestamp_relative)
                .components()
                .any(|component| !matches!(component, Component::Normal(_)))
        {
            return Err("maintenance.skill_improver.timestamp must be a safe ~/ path".to_string());
        }

        for pin in ["brainstorming", "writing_plans", "writing_skills"] {
            let value = self
                .superpowers
                .adapted_from
                .get(pin)
                .ok_or_else(|| format!("superpowers.adapted_from missing pin: {pin}"))?;
            require_text(&format!("superpowers.adapted_from.{pin}"), value)?;
        }
        if self
            .superpowers
            .optional_disciplines
            .iter()
            .chain(&self.superpowers.excluded_workflow_skills)
            .any(|name| name.trim().is_empty())
        {
            return Err("superpowers skill names must not be empty".to_string());
        }
        Ok(())
    }
}

impl Artifact {
    pub fn template(&self) -> Option<&str> {
        self.path.as_deref().or(self.pattern.as_deref())
    }
}

fn require_keys<T>(kind: &str, keys: &[&str], values: &BTreeMap<String, T>) -> Result<(), String> {
    for key in keys {
        if !values.contains_key(*key) {
            return Err(format!("workflow contract missing {kind}: {key}"));
        }
    }
    Ok(())
}

fn require_text(name: &str, value: &str) -> Result<(), String> {
    if value.trim().is_empty() {
        Err(format!("{name} must not be empty"))
    } else {
        Ok(())
    }
}

fn validate_relative(name: &str, value: &str) -> Result<(), String> {
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
        Err(format!("{name} must be a safe relative path: {value}"))
    } else {
        Ok(())
    }
}

fn validate_tokens(name: &str, value: &str) -> Result<(), String> {
    let remainder = value.replace("{feature}", "").replace("{round}", "");
    if remainder.contains('{') || remainder.contains('}') {
        Err(format!(
            "{name} contains an unsupported template token: {value}"
        ))
    } else {
        Ok(())
    }
}

fn template_matches(template: &str, value: &str) -> bool {
    let pattern = template.replace("{feature}", "*").replace("{round}", "*");
    wildcard_matches(pattern.as_bytes(), value.as_bytes())
}

fn wildcard_matches(pattern: &[u8], value: &[u8]) -> bool {
    match pattern.split_first() {
        None => value.is_empty(),
        Some((&b'*', rest)) => {
            (1..=value.len()).any(|consumed| wildcard_matches(rest, &value[consumed..]))
        }
        Some((&expected, rest)) => value
            .split_first()
            .is_some_and(|(&actual, tail)| expected == actual && wildcard_matches(rest, tail)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_contract_is_valid() {
        let contract = load().expect("embedded workflow contract must be valid");
        assert_eq!(contract.schema_version, 1);
        assert_eq!(contract.artifact("plan").unwrap().writer, "annotate-plan");
        assert_eq!(
            contract
                .superpowers
                .adapted_from
                .get("writing_skills")
                .map(String::as_str),
            Some("6.3.0")
        );
    }

    #[test]
    fn rejects_absolute_and_parent_paths() {
        let invalid = include_str!("../../../workflow-contract.json").replacen(
            "\"spec.md\"",
            "\"../spec.md\"",
            1,
        );
        assert!(parse(&invalid).is_err());

        let invalid_timestamp = include_str!("../../../workflow-contract.json").replacen(
            "\"~/.claude/.last_skill_improver_run\"",
            "\"~/../outside\"",
            1,
        );
        assert!(parse(&invalid_timestamp).is_err());
    }

    #[test]
    fn templates_match_feature_and_round() {
        let contract = load().unwrap();
        assert!(contract.matches_artifact("evaluation_report", ".plans/.evaluation-auth-r2.md"));
        assert!(!contract.matches_artifact("evaluation_report", ".plans/.qa-auth-r2.md"));
    }
}
