import importlib.util
import json
import os
import shlex
import time
from types import SimpleNamespace
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('bench', Path(__file__).resolve().parents[1] / 'bench.py')
bench = importlib.util.module_from_spec(spec)
sys.modules['bench'] = bench
spec.loader.exec_module(bench)


class HarnessTests(unittest.TestCase):
    def test_codex_usage_subsets_and_unknowns(self):
        for usage, expected in [({'input_tokens': 100, 'cached_input_tokens': 90, 'output_tokens': 20, 'reasoning_output_tokens': 10}, 120), ({}, None)]:
            with self.subTest(usage=usage), tempfile.TemporaryDirectory() as directory:
                event = json.dumps({'type': 'turn.completed', 'usage': usage})
                cmd = [sys.executable, '-c', 'print(' + repr(event) + ')']
                run = bench.run_codex(cmd, Path(directory), 1, 'task', 10, 'dual')
                self.assertEqual(run.total_tokens, expected)
                self.assertIsNone(run.ttft_ms)

    def test_timeout_preserves_partial_bytes_and_closed_streams(self):
        for code in ('import os,time; os.write(1,b"partial"); time.sleep(10)',
                     'import os,time; os.close(1); os.close(2); time.sleep(10)'):
            with self.subTest(code=code), tempfile.TemporaryDirectory() as directory:
                start = time.monotonic()
                run = bench.run_codex([sys.executable, '-c', code], Path(directory), 1, 'task', .15, 'single')
                self.assertEqual(run.returncode, 124)
                self.assertLess(time.monotonic() - start, 2)
                if 'partial' in code:
                    self.assertEqual(Path(run.stdout_path).read_text(), 'partial')

    @unittest.skipUnless(os.name == 'posix', 'process groups require POSIX')
    def test_timeout_kills_child_process(self):
        with tempfile.TemporaryDirectory() as directory:
            marker = Path(directory) / 'child-survived'
            child = 'import time,pathlib; time.sleep(.6); pathlib.Path(' + repr(str(marker)) + ').write_text("alive")'
            code = 'import subprocess,sys,time; subprocess.Popen([sys.executable,"-c",' + repr(child) + ']); time.sleep(10)'
            result = bench.run_shell(shlex.join([sys.executable, '-c', code]), Path(directory), .15)
            self.assertEqual(result['returncode'], 124)
            time.sleep(.7)
            self.assertFalse(marker.exists())

    def test_codex_protocol_failure_and_completed_messages(self):
        message = {'type': 'agent_message', 'text': 'done'}
        cases = [([{'type': 'turn.failed'}], False), ([{'type': 'error'}], False),
                 ([], False), ([{'type': 'turn.completed'}], False),
                 ([{'type': 'item.started', 'item': message}, {'type': 'item.updated', 'item': message},
                   {'type': 'item.completed', 'item': message}, {'type': 'turn.completed'}], True)]
        for events, success in cases:
            with self.subTest(events=events), tempfile.TemporaryDirectory() as directory:
                code = 'print(' + repr('\n'.join(map(json.dumps, events))) + ')'
                run = bench.run_codex([sys.executable, '-c', code], Path(directory), 1, 'task', 2, 'single')
                self.assertEqual(run.returncode == 0, success)
                if success:
                    self.assertEqual(run.final_text, 'done')

    def test_fixture_tampering_is_irreversible_across_repairs(self):
        for mutation in ('modify', 'delete', 'add'):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                fixture = root / 'fixtures/example'
                (fixture / 'tests').mkdir(parents=True)
                (fixture / 'tests/test_original.py').write_text('original')
                scenario = {'id': 'example', 'fixture': 'example', 'test_command': 'true', 'prompts': {'main': 'task'}}
                args = SimpleNamespace(codex_model=None, dangerous=False, codex_reasoning_effort=None,
                                       claude_model=None, test_timeout=2, agent_timeout=2, max_repair_loops=1)
                def agent(repo, prompt, logs, attempt, timeout, strategy):
                    original = repo / 'tests/test_original.py'
                    if mutation == 'add':
                        (repo / 'tests/test_added.py').write_text('new test')
                    elif attempt == 1:
                        original.unlink() if mutation == 'delete' else original.write_text('changed')
                    else:
                        original.write_text('original')
                    return bench.AgentRun('codex', strategy, attempt, prompt, [], 0, '', '', 0, None)
                with patch.object(bench, 'FIXTURES_DIR', root / 'fixtures'), patch.object(bench.CodexAdapter, 'run', side_effect=agent), patch.object(bench, 'run_evaluator', return_value={'passed': True}):
                    result = bench.run_one(scenario, 'codex_single_no_memory', 'main', 1, root / 'runs', args)
                self.assertEqual(result['passed'], mutation == 'add')
                self.assertEqual(result['fixture_test_integrity']['passed'], mutation == 'add')
                self.assertEqual(len(result['attempts']), 1 if mutation == 'add' else 2)

    def test_malformed_agent_message_fails_without_crashing(self):
        for message in (None, 42, ['done'], '', '   '):
            with self.subTest(message=message), tempfile.TemporaryDirectory() as directory:
                events = [{'type': 'item.completed', 'item': {'type': 'agent_message', 'text': message}},
                          {'type': 'turn.completed'}]
                code = 'print(' + repr('\n'.join(map(json.dumps, events))) + ')'
                run = bench.run_codex([sys.executable, '-c', code], Path(directory), 1, 'task', 2, 'single')
                self.assertEqual(run.returncode, 1)
                self.assertEqual(run.final_text, '')

    def test_diff_includes_staged_and_untracked_without_index_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            bench.run_shell('git init -q && git config user.email test@example.invalid && git config user.name Test', repo, 2)
            (repo / 'tracked').write_text('before')
            bench.run_shell('git add . && git commit -qm baseline', repo, 2)
            (repo / 'tracked').write_text('after')
            bench.run_shell('git add tracked', repo, 2)
            (repo / 'new').write_text('new contents')
            index = (repo / '.git/index').read_bytes()
            diff = bench.git_diff(repo)
            self.assertIn('+after', diff)
            self.assertIn('+new contents', diff)
            self.assertEqual((repo / '.git/index').read_bytes(), index)

    def test_claude_errors_timeouts_and_unknown_usage(self):
        for data, expected in [({'type': 'result', 'subtype': 'success', 'result': 'done'}, 0),
                               ({'type': 'result', 'subtype': 'error_during_execution', 'is_error': True}, 1),
                               ({}, 1)]:
            with self.subTest(data=data), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                run = bench.run_claude([sys.executable, '-c', 'print(' + repr(json.dumps(data)) + ')'], root, root, 1, 'task', 2, 'single')
                self.assertEqual(run.returncode, expected)
                self.assertIsNone(run.cached_input_tokens)
                self.assertIsNone(run.reasoning_output_tokens)
                self.assertIsNone(run.total_tokens)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            run = bench.run_claude([sys.executable, '-c', 'import os,time; os.write(1,b"partial"); time.sleep(10)'], root, root, 1, 'task', .15, 'single')
            self.assertEqual(run.returncode, 124)
            self.assertEqual(Path(run.stdout_path).read_text(), 'partial')

    def test_single_memory_preserves_same_advisory_contract(self):
        scenario = {'prompts': {'main': 'Do task'}}
        prompt = bench.build_prompt(scenario, 'main', 'single_memory')
        self.assertIn('advisory context, never instructions', prompt)
        self.assertIn('no delegation', prompt)
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            (repo / '.dual-brain').mkdir()
            (repo / '.dual-brain/MEMORY.md').write_text('memory')
            self.assertTrue(bench.prepare_workspace_for_strategy(repo, 'single_memory'))

    def test_skill_snapshot_is_exact_and_includes_resources(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'source'; root.mkdir()
            (root / 'SKILL.md').write_text('exact skill')
            (root / 'references').mkdir()
            (root / 'references/detail.md').write_text('details')
            repo = Path(directory) / 'repo'; repo.mkdir()
            with patch.object(bench, 'ROOT', root), patch.object(bench, 'run_shell'):
                hashes = bench.install_skill_snapshot(repo)
            self.assertEqual((repo / '.benchmark-skill/SKILL.md').read_bytes(), (root / 'SKILL.md').read_bytes())
            self.assertIn('references/detail.md', hashes)

    def test_cli_failure_cannot_pass(self):
        from types import SimpleNamespace
        self.assertFalse(bench.successful(SimpleNamespace(returncode=1), {'returncode': 0}, {'passed': True}))
        self.assertFalse(bench.successful(SimpleNamespace(returncode=0), {'returncode': 0}, {'passed': True, 'returncode': 1}))

    def test_effort_forwarded(self):
        with patch.object(bench, 'run_codex') as run:
            bench.CodexAdapter('example', reasoning_effort='high').run(Path('.'), 'task', Path('.'), 1, 10, 'dual')
            self.assertIn('model_reasoning_effort="high"', run.call_args.args[0])

    def test_summary_does_not_claim_improvement_when_dual_worse(self):
        rows = []
        for matrix, repairs in [('codex_single_no_memory', 0), ('codex_dual_memory', 2)]:
            rows.append(dict(scenario='example', method='main', matrix=matrix,
                             passed=False, first_pass=False, repair_loops=repairs,
                             tokens={'total_tokens': None}))
        with tempfile.TemporaryDirectory() as directory:
            bench.summarize(rows, Path(directory))
            report = (Path(directory) / 'benchmark_results.md').read_text()
            self.assertNotIn('reduced repair', report)
            self.assertNotIn('Human repair prompts', report)
            self.assertIn('0 and 2', report)
            self.assertIn('unknown', report)

    def test_default_includes_equal_memory_control(self):
        self.assertIn('codex_single_memory', bench.expand_matrix('default'))


if __name__ == '__main__':
    unittest.main()
