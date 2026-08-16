use anyhow::{Context, Result, anyhow};
use std::fs;
use std::path::Path;

pub type Frontmatter = serde_yaml::Mapping;

/// Parse result: the frontmatter mapping plus the body line count
/// (lines after the closing `---`).
#[derive(Debug)]
pub struct ParsedSkill {
    pub frontmatter: Frontmatter,
    pub body_lines: usize,
    pub raw: String,
}

pub fn parse_from_file(path: &Path) -> Result<ParsedSkill> {
    let content =
        fs::read_to_string(path).with_context(|| format!("failed to read {}", path.display()))?;
    parse_from_str(&content)
}

pub fn parse_from_str(content: &str) -> Result<ParsedSkill> {
    let mut lines_iter = content.lines();
    let first = lines_iter.next().unwrap_or("");
    if first != "---" {
        return Err(anyhow!(
            "first line must be '---' (got: '{}')",
            first.chars().take(40).collect::<String>()
        ));
    }

    let mut yaml_text = String::new();
    let mut closing_line: Option<usize> = None;
    for (idx, line) in lines_iter.enumerate() {
        if line == "---" {
            // idx is 0-based from the line *after* the opening ---;
            // total lines consumed including both delimiters = idx + 2.
            closing_line = Some(idx + 2);
            break;
        }
        yaml_text.push_str(line);
        yaml_text.push('\n');
    }

    let closing = closing_line.ok_or_else(|| anyhow!("closing '---' delimiter not found"))?;

    let value: serde_yaml::Value =
        serde_yaml::from_str(&yaml_text).context("failed to parse YAML frontmatter")?;
    let mapping = match value {
        serde_yaml::Value::Mapping(m) => m,
        serde_yaml::Value::Null => serde_yaml::Mapping::new(),
        _ => return Err(anyhow!("frontmatter must be a YAML mapping")),
    };

    let total_lines = content.lines().count();
    let body_lines = total_lines.saturating_sub(closing);

    Ok(ParsedSkill {
        frontmatter: mapping,
        body_lines,
        raw: content.to_string(),
    })
}

pub fn get_str<'a>(fm: &'a Frontmatter, key: &str) -> Option<&'a str> {
    fm.get(serde_yaml::Value::String(key.to_string()))
        .and_then(|v| v.as_str())
}

pub fn get_value<'a>(fm: &'a Frontmatter, key: &str) -> Option<&'a serde_yaml::Value> {
    fm.get(serde_yaml::Value::String(key.to_string()))
}

pub fn keys(fm: &Frontmatter) -> impl Iterator<Item = &str> {
    fm.keys().filter_map(|k| k.as_str())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_minimal_frontmatter() {
        let s = "---\nname: foo\ndescription: bar\n---\n\n# Body\nline 1\n";
        let parsed = parse_from_str(s).unwrap();
        assert_eq!(parsed.frontmatter.len(), 2);
        assert_eq!(get_str(&parsed.frontmatter, "name"), Some("foo"));
        assert_eq!(parsed.body_lines, 3);
    }

    #[test]
    fn rejects_missing_opening() {
        let s = "name: foo\n---\n";
        assert!(parse_from_str(s).is_err());
    }

    #[test]
    fn rejects_missing_closing() {
        let s = "---\nname: foo\nstill: no closing\n";
        assert!(parse_from_str(s).is_err());
    }

    #[test]
    fn accepts_empty_frontmatter() {
        let s = "---\n---\n";
        let parsed = parse_from_str(s).unwrap();
        assert!(parsed.frontmatter.is_empty());
    }

    #[test]
    fn extracts_boolean_field() {
        let s = "---\nname: foo\ndisable-model-invocation: true\n---\nbody\n";
        let parsed = parse_from_str(s).unwrap();
        let v = get_value(&parsed.frontmatter, "disable-model-invocation").unwrap();
        assert_eq!(v.as_bool(), Some(true));
    }
}
