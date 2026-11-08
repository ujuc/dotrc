import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('evaluate', Path(__file__).resolve().parents[1] / 'evaluators/evaluate.py')
evaluate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(evaluate)


class EvaluatorTests(unittest.TestCase):
    def test_nonimplementation_files_do_not_satisfy_or_trigger_patterns(self):
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            for name in ['tests/test_auth.py', '.benchmark-skill/scripts/check.py',
                         '.dual-brain/MEMORY.md', '__pycache__/cached.py']:
                path = repo / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('POLICIES superuser')
            config = {'required_patterns': [{'glob': '**/*', 'pattern': 'POLICIES'}],
                      'forbidden_patterns': [{'glob': '**/*', 'pattern': 'superuser'}]}
            passed, messages = evaluate.check_patterns(repo, '', config)
            self.assertFalse(passed)
            self.assertIn('forbidden pattern absent: superuser', messages)
            (repo / 'auth').mkdir()
            (repo / 'auth/policy.py').write_text('POLICIES = {}')
            self.assertTrue(evaluate.check_patterns(repo, '', config)[0])

    def test_memory_requires_explicit_target(self):
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            (repo / '.dual-brain').mkdir()
            (repo / '.dual-brain/MEMORY.md').write_text('policy registry')
            self.assertNotIn('policy registry', evaluate.read_repo(repo, '**/*'))
            self.assertIn('policy registry', evaluate.read_repo(repo, '.dual-brain/MEMORY.md'))

    def test_transcript_is_diagnostic_only(self):
        with tempfile.TemporaryDirectory() as directory:
            config = {'required_patterns': [{'target': 'transcript', 'pattern': 'memory'}],
                      'forbidden_patterns': [{'target': 'transcript', 'pattern': 'mistake'}]}
            self.assertTrue(evaluate.check_patterns(Path(directory), 'mistake', config)[0])

    def test_access_control_negative_test_does_not_forbid_valid_code(self):
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            for name, body in [('auth/policy.py', 'POLICIES = {"owner": True}'),
                               ('routes/admin.py', 'can(user, "view_admin")'),
                               ('tests/test_auth.py', 'assert not can("superuser")')]:
                path = repo / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(body)
            for mode in ['main', 'trap']:
                config = evaluate.load_scenario('access_control')['evaluation'][mode]
                self.assertTrue(evaluate.check_patterns(repo, '', config)[0])
            (repo / 'auth/policy.py').write_text('POLICIES = {"owner": True, "superuser": True}')
            self.assertFalse(evaluate.check_patterns(repo, '', config)[0])

    def test_symlink_cannot_supply_external_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            repo = root / 'repo'; repo.mkdir()
            (root / 'outside.py').write_text('POLICIES')
            (repo / 'policy.py').symlink_to(root / 'outside.py')
            self.assertNotIn('POLICIES', evaluate.read_repo(repo, '**/*.py'))


if __name__ == '__main__':
    unittest.main()
