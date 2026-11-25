// Loads the skills Claude Code uses: installed marketplace plugins (at their
// installed version only) and the nested personal skill roots under ~/.claude/skills.
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const claude = join(homedir(), ".claude");
const personal = ["ujuc/skills", "egm/skills", "skill-diet/skills", "dual-brain"];

function pluginSkillDirs(): string[] {
	try {
		const registry = JSON.parse(readFileSync(join(claude, "plugins/installed_plugins.json"), "utf8"));
		return Object.values(registry.plugins ?? {})
			.flatMap((installs: any) => (Array.isArray(installs) ? installs : []))
			.filter((install: any) => install.scope === "user" && install.installPath)
			.map((install: any) => join(install.installPath, "skills"));
	} catch {
		return [];
	}
}

export default function (pi) {
	pi.on("resources_discover", () => ({
		skillPaths: [...personal.map((dir) => join(claude, "skills", dir)), ...pluginSkillDirs()].filter(existsSync),
	}));
}
