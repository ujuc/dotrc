import importlib.util
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[2] / "scripts/export_portable.py"
spec = importlib.util.spec_from_file_location("export_portable", SCRIPT)
export_portable = importlib.util.module_from_spec(spec)
spec.loader.exec_module(export_portable)


class PortableTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name) / "source"
        (self.root / "references").mkdir(parents=True)
        (self.root / "scripts").mkdir()
        shutil.copyfile(SCRIPT, self.root / "scripts/export_portable.py")
        self.bodies = {
            "SKILL.md": (
                "# Workflow\n\nKeep every rule, including café and 한글.\n\n"
                "[Runtime](references/runtime.md) and [Memory](./references/memory.md).\n\n"
                "A clean review may finish without edits.\n"
            ),
            "references/runtime.md": (
                "# Runtime\n\nUse only available tools.\n\n"
                "[Workflow](../SKILL.md) and [Memory](memory.md).\n\n"
                "[External](https://example.com/references/memory.md) stays external.\n"
            ),
            "references/memory.md": (
                "# Memory\n\nDo not save unchanged review history.\n\n"
                "```md\n- Preserve this complete example.\n```\n\n"
                "The final rule must survive export.\n"
            ),
        }
        for name, body in self.bodies.items():
            if name == "SKILL.md":
                body = "---\nname: fixture\ndescription: metadata only\n---\n\n" + body
            (self.root / name).write_text(body, encoding="utf-8")
        (self.root / "INSTALL.md").write_text("UNRELATED INSTALLATION INSTRUCTIONS")

    def run_cli(self, *arguments):
        return subprocess.run(
            [sys.executable, str(self.root / "scripts/export_portable.py"), *arguments],
            cwd=self.directory.name, text=True, capture_output=True, check=False,
        )

    def test_complete_sources_are_preserved_except_frontmatter_and_links(self):
        result = export_portable.build_portable(self.root)
        expected_bodies = dict(self.bodies)
        expected_bodies["SKILL.md"] = expected_bodies["SKILL.md"].replace(
            "(references/runtime.md)", "(#dual-brain-runtime)"
        ).replace("(./references/memory.md)", "(#dual-brain-memory)")
        expected_bodies["references/runtime.md"] = expected_bodies["references/runtime.md"].replace(
            "(../SKILL.md)", "(#dual-brain-workflow)"
        ).replace("(memory.md)", "(#dual-brain-memory)")
        for body in expected_bodies.values():
            self.assertIn(body.strip(), result)
        for anchor in ("dual-brain-workflow", "dual-brain-runtime", "dual-brain-memory"):
            self.assertIn(f'<a id="{anchor}"></a>', result)
        self.assertNotIn("description: metadata only", result)
        self.assertNotIn("UNRELATED INSTALLATION INSTRUCTIONS", result)
        self.assertEqual(result, export_portable.build_portable(self.root))

    def test_links_to_subheadings_and_unincluded_files_are_preserved(self):
        result = export_portable.local_links_to_anchors(
            "[Section](memory.md#save-and-compact) [Other](other.md) [Here](#local) "
            '[Title](../SKILL.md "workflow")',
            "references/runtime.md",
        )
        self.assertEqual(result, '[Section](#save-and-compact) [Other](other.md) [Here](#local) '
                         '[Title](#dual-brain-workflow "workflow")')

    def test_cli_generates_at_source_root_and_check_never_repairs_output(self):
        output = self.root / "PORTABLE.md"
        self.assertNotEqual(self.run_cli("--check").returncode, 0)
        self.assertFalse(output.exists())
        generated = self.run_cli()
        self.assertEqual(generated.returncode, 0, generated.stderr)
        self.assertFalse((Path(self.directory.name) / "PORTABLE.md").exists())
        self.assertEqual(output.read_bytes(), export_portable.build_portable(self.root).encode("utf-8"))
        original_stat = output.stat()
        self.assertEqual(self.run_cli("--check").returncode, 0)
        self.assertEqual(output.stat().st_mtime_ns, original_stat.st_mtime_ns)
        output.write_text("stale output", encoding="utf-8")
        checked = self.run_cli("--check")
        self.assertNotEqual(checked.returncode, 0)
        self.assertIn("stale", checked.stderr)
        self.assertEqual(output.read_text(encoding="utf-8"), "stale output")

    def test_check_detects_source_changes_and_output_option(self):
        output = Path(self.directory.name) / "custom.md"
        generated = self.run_cli("--output", str(output))
        self.assertEqual(generated.returncode, 0, generated.stderr)
        self.assertFalse((self.root / "PORTABLE.md").exists())
        self.assertEqual(self.run_cli("--output", str(output), "--check").returncode, 0)
        original = output.read_bytes()
        with (self.root / "references/memory.md").open("a", encoding="utf-8") as source:
            source.write("\nNew authoritative rule.\n")
        self.assertNotEqual(self.run_cli("--output", str(output), "--check").returncode, 0)
        self.assertEqual(output.read_bytes(), original)
        self.assertEqual(self.run_cli("--output", str(output)).returncode, 0)
        self.assertIn("New authoritative rule.", output.read_text(encoding="utf-8"))

    def test_invalid_or_missing_source_fails_without_partial_output(self):
        (self.root / "SKILL.md").write_text("---\nname: incomplete\n", encoding="utf-8")
        result = self.run_cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unterminated YAML frontmatter", result.stderr)
        self.assertFalse((self.root / "PORTABLE.md").exists())
        (self.root / "SKILL.md").write_text(self.bodies["SKILL.md"], encoding="utf-8")
        (self.root / "references/runtime.md").unlink()
        self.assertNotEqual(self.run_cli().returncode, 0)
        self.assertFalse((self.root / "PORTABLE.md").exists())


if __name__ == "__main__":
    unittest.main()
