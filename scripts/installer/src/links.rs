//! Managed symlinks: the static link list, its preflight, link creation, and the
//! migration of pre-584a9dc whole-directory agent links.

use std::fs;
use std::io;
use std::path::{Path, PathBuf};

use crate::runner::{Runner, shell_words};

#[derive(Clone, Copy, Default, Debug, PartialEq, Eq)]
pub struct Groups {
    pub cli: bool,
    pub apps: bool,
    pub fonts: bool,
    pub agents: bool,
}

pub struct Layout {
    pub dotrc: PathBuf,
    pub home: PathBuf,
    pub xdg_config: PathBuf,
}

impl Layout {
    pub fn agents(&self) -> PathBuf {
        self.dotrc.join("agents")
    }

    fn shared_agents_md(&self) -> PathBuf {
        self.agents().join("claude/AGENTS.global.md")
    }

    pub fn cli_links(&self) -> Vec<(PathBuf, PathBuf)> {
        vec![
            (
                self.dotrc.join("starship.toml"),
                self.xdg_config.join("starship.toml"),
            ),
            (self.dotrc.join("zshrc"), self.home.join(".zshrc")),
            (self.dotrc.join("batrc"), self.xdg_config.join("bat/config")),
            (self.dotrc.join("tigrc"), self.xdg_config.join("tig/config")),
        ]
    }

    pub fn app_links(&self) -> Vec<(PathBuf, PathBuf)> {
        vec![(
            self.dotrc.join("ghosttyrc"),
            self.xdg_config.join("ghostty/config"),
        )]
    }

    pub fn agent_links(&self) -> Vec<(PathBuf, PathBuf)> {
        vec![
            (self.agents().join("claude"), self.home.join(".claude")),
            (self.shared_agents_md(), self.home.join(".codex/AGENTS.md")),
            (
                self.shared_agents_md(),
                self.home.join(".omp/agent/AGENTS.md"),
            ),
            (
                self.shared_agents_md(),
                self.home.join(".pi/agent/AGENTS.md"),
            ),
            (
                self.shared_agents_md(),
                self.xdg_config.join("amp/AGENTS.md"),
            ),
            (
                self.agents().join("pi-extensions/claude-skills.ts"),
                self.home.join(".pi/agent/extensions/claude-skills.ts"),
            ),
        ]
    }

    /// Every link the selected groups create; README documents each target.
    pub fn selected_links(&self, groups: Groups) -> Vec<(PathBuf, PathBuf)> {
        let mut links = Vec::new();
        if groups.cli {
            links.extend(self.cli_links());
        }
        if groups.apps {
            links.extend(self.app_links());
        }
        if groups.agents {
            links.extend(self.agent_links());
        }
        links
    }

    /// Before 584a9dc these whole directories were links into `agents/`.
    fn legacy_agent_dirs(&self) -> [(PathBuf, &'static str); 3] {
        [
            (self.home.join(".codex"), "codex"),
            (self.xdg_config.join("amp"), "amp"),
            (self.home.join(".pi"), "pi"),
        ]
    }

    /// The exact old target, or a dangling link left by a checkout that has since moved.
    fn is_legacy_agent_link(&self, link: &Path, name: &str) -> bool {
        let Ok(target) = fs::read_link(link) else {
            return false;
        };
        if target == self.agents().join(name) {
            return true;
        }
        !link.exists()
            && target
                .to_string_lossy()
                .ends_with(&format!("/agents/{name}"))
    }

    /// The path goes through a link that `migrate_legacy_agent_dirs` replaces,
    /// so the preflight judges it after that.
    fn inside_legacy_agent_link(&self, path: &Path) -> bool {
        self.legacy_agent_dirs().iter().any(|(link, name)| {
            path.starts_with(link) && path != link && self.is_legacy_agent_link(link, name)
        })
    }

    pub fn check_destination(&self, source: &Path, destination: &Path) -> Result<(), String> {
        if !source.exists() {
            return Err(format!("Link source missing: {}", source.display()));
        }
        if self.inside_legacy_agent_link(destination) {
            return Ok(());
        }
        match fs::read_link(destination) {
            Ok(target) if target == source => Ok(()),
            Ok(_) => Err(format!("Link conflict: {}", destination.display())),
            Err(_) if fs::symlink_metadata(destination).is_err() => Ok(()),
            Err(_) => Err(format!("Link conflict: {}", destination.display())),
        }
    }

    /// Checks every selected link before any step runs; returns the problems found.
    pub fn preflight(&self, groups: Groups) -> Vec<String> {
        self.selected_links(groups)
            .iter()
            .filter_map(|(source, destination)| self.check_destination(source, destination).err())
            .collect()
    }

    /// Replaces each legacy link with a real directory. Runtime state left under
    /// the old target (auth, sessions) moves along; nothing is deleted.
    pub fn migrate_legacy_agent_dirs(&self, runner: &mut Runner) {
        for (destination, name) in self.legacy_agent_dirs() {
            if !self.is_legacy_agent_link(&destination, name) {
                continue;
            }
            let legacy = self.agents().join(name);
            let target = fs::read_link(&destination).ok();
            let shown = shell_words(["rm", &destination.to_string_lossy()]);
            runner.run_native(
                "links",
                &format!("Remove legacy link {}", destination.display()),
                shown,
                || fs::remove_file(&destination),
            );
            if runner.last_status != 0
                || target.as_deref() != Some(legacy.as_path())
                || !legacy.is_dir()
            {
                continue;
            }
            runner.run(
                "links",
                &format!("Move legacy {name} state to {}", destination.display()),
                "mv",
                &[&legacy.to_string_lossy(), &destination.to_string_lossy()],
            );
            let old = destination.join("AGENTS.md");
            if runner.last_status == 0
                && fs::symlink_metadata(&old).is_ok_and(|meta| meta.is_file())
            {
                let kept = destination.join("AGENTS.md.legacy");
                let shown = shell_words(["mv", &old.to_string_lossy(), &kept.to_string_lossy()]);
                runner.run_native(
                    "links",
                    &format!("Keep old {} as AGENTS.md.legacy", old.display()),
                    shown,
                    || fs::rename(&old, &kept),
                );
            }
        }
    }
}

/// `mkdir -p` the parent, then `ln -sfn` the link.
pub fn safe_link(runner: &mut Runner, source: &Path, destination: &Path) {
    if !source.exists() {
        runner.record(
            "links",
            &format!("Source exists: {}", source.display()),
            1,
            format!("test -e {}", source.display()),
        );
        return;
    }
    let parent = destination.parent().unwrap_or(Path::new("/")).to_path_buf();
    runner.run_native(
        "links",
        &format!("Create parent for {}", destination.display()),
        shell_words(["mkdir", "-p", &parent.to_string_lossy()]),
        || fs::create_dir_all(&parent),
    );
    if runner.last_status != 0 {
        return;
    }
    runner.run_native(
        "links",
        &format!("Link {}", destination.display()),
        shell_words([
            "ln",
            "-sfn",
            &source.to_string_lossy(),
            &destination.to_string_lossy(),
        ]),
        || replace_link(source, destination),
    );
}

fn replace_link(source: &Path, destination: &Path) -> io::Result<()> {
    if fs::symlink_metadata(destination).is_ok_and(|meta| meta.file_type().is_symlink()) {
        fs::remove_file(destination)?;
    }
    std::os::unix::fs::symlink(source, destination)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::symlink;
    use std::sync::atomic::{AtomicUsize, Ordering};

    struct Fixture {
        root: PathBuf,
        layout: Layout,
    }

    impl Drop for Fixture {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    fn fixture() -> Fixture {
        static NEXT: AtomicUsize = AtomicUsize::new(0);
        let root = std::env::temp_dir().join(format!(
            "dotrc-installer-test-{}-{}",
            std::process::id(),
            NEXT.fetch_add(1, Ordering::Relaxed)
        ));
        let layout = Layout {
            dotrc: root.join("dotrc"),
            home: root.join("home"),
            xdg_config: root.join("home/.config"),
        };
        fs::create_dir_all(layout.agents().join("claude")).unwrap();
        fs::create_dir_all(&layout.xdg_config).unwrap();
        fs::write(layout.shared_agents_md(), "shared\n").unwrap();
        fs::create_dir_all(layout.agents().join("pi-extensions")).unwrap();
        fs::write(layout.agents().join("pi-extensions/claude-skills.ts"), "").unwrap();
        Fixture { root, layout }
    }

    const AGENTS: Groups = Groups {
        cli: false,
        apps: false,
        fonts: false,
        agents: true,
    };

    fn install_agent_links(layout: &Layout, runner: &mut Runner) {
        layout.migrate_legacy_agent_dirs(runner);
        for (source, destination) in layout.agent_links() {
            safe_link(runner, &source, &destination);
        }
    }

    #[test]
    fn selected_links_follow_groups() {
        let f = fixture();
        assert!(f.layout.selected_links(Groups::default()).is_empty());
        assert_eq!(f.layout.selected_links(AGENTS).len(), 6);
        let all = Groups {
            cli: true,
            apps: true,
            fonts: true,
            agents: true,
        };
        assert_eq!(f.layout.selected_links(all).len(), 11);
    }

    #[test]
    fn preflight_accepts_missing_and_matching_links_and_rejects_conflicts() {
        let f = fixture();
        let (source, destination) = &f.layout.agent_links()[0];
        assert!(f.layout.check_destination(source, destination).is_ok());
        fs::create_dir_all(&f.layout.home).unwrap();
        symlink(source, destination).unwrap();
        assert!(f.layout.check_destination(source, destination).is_ok());
        fs::remove_file(destination).unwrap();
        fs::write(destination, "real file").unwrap();
        assert!(f.layout.check_destination(source, destination).is_err());
        let missing = f.layout.dotrc.join("missing");
        assert!(
            f.layout
                .check_destination(&missing, &f.layout.home.join("x"))
                .is_err()
        );
    }

    #[test]
    fn legacy_link_with_state_is_migrated_and_old_agents_md_kept() {
        let f = fixture();
        let codex = f.layout.agents().join("codex");
        fs::create_dir_all(codex.join("sessions")).unwrap();
        fs::write(codex.join("auth.json"), "token").unwrap();
        fs::write(codex.join("AGENTS.md"), "old").unwrap();
        fs::create_dir_all(&f.layout.home).unwrap();
        symlink(&codex, f.layout.home.join(".codex")).unwrap();
        symlink("/old/place/agents/pi", f.layout.home.join(".pi")).unwrap();
        symlink(
            f.layout.agents().join("amp"),
            f.layout.xdg_config.join("amp"),
        )
        .unwrap();

        assert!(f.layout.preflight(AGENTS).is_empty());
        let mut runner = Runner::new();
        install_agent_links(&f.layout, &mut runner);

        assert!(
            runner.failures.is_empty(),
            "{:?}",
            runner.failures.iter().map(|x| &x.label).collect::<Vec<_>>()
        );
        let home_codex = f.layout.home.join(".codex");
        assert!(
            !fs::symlink_metadata(&home_codex)
                .unwrap()
                .file_type()
                .is_symlink()
        );
        assert_eq!(
            fs::read_to_string(home_codex.join("auth.json")).unwrap(),
            "token"
        );
        assert_eq!(
            fs::read_to_string(home_codex.join("AGENTS.md.legacy")).unwrap(),
            "old"
        );
        assert_eq!(
            fs::read_link(home_codex.join("AGENTS.md")).unwrap(),
            f.layout.shared_agents_md()
        );
        assert_eq!(
            fs::read_link(f.layout.home.join(".pi/agent/AGENTS.md")).unwrap(),
            f.layout.shared_agents_md()
        );
        let amp = f.layout.xdg_config.join("amp");
        assert!(!fs::symlink_metadata(&amp).unwrap().file_type().is_symlink());
        assert_eq!(
            fs::read_link(amp.join("AGENTS.md")).unwrap(),
            f.layout.shared_agents_md()
        );
        assert!(!codex.exists());

        let mut again = Runner::new();
        assert!(f.layout.preflight(AGENTS).is_empty());
        install_agent_links(&f.layout, &mut again);
        assert!(again.failures.is_empty());
    }

    #[test]
    fn real_agents_md_file_blocks_preflight() {
        let f = fixture();
        fs::create_dir_all(f.layout.home.join(".codex")).unwrap();
        fs::write(f.layout.home.join(".codex/AGENTS.md"), "mine").unwrap();
        assert_eq!(f.layout.preflight(AGENTS).len(), 1);
    }

    #[test]
    fn unrelated_symlink_is_not_legacy() {
        let f = fixture();
        let other = f.root.join("otherpi");
        fs::create_dir_all(&other).unwrap();
        fs::create_dir_all(&f.layout.home).unwrap();
        symlink(&other, f.layout.home.join(".pi")).unwrap();
        let mut runner = Runner::new();
        install_agent_links(&f.layout, &mut runner);
        assert!(runner.failures.is_empty());
        assert_eq!(fs::read_link(f.layout.home.join(".pi")).unwrap(), other);
        assert!(other.join("agent/AGENTS.md").exists());
    }

    #[test]
    fn missing_source_is_recorded_not_linked() {
        let f = fixture();
        let mut runner = Runner::new();
        safe_link(
            &mut runner,
            &f.layout.dotrc.join("absent"),
            &f.layout.home.join(".absent"),
        );
        assert_eq!(runner.failures.len(), 1);
        assert!(fs::symlink_metadata(f.layout.home.join(".absent")).is_err());
    }
}
