from pathlib import Path
import runpy
import unittest

API = runpy.run_path(str(Path(__file__).with_name("check-required.py")))
WORKFLOW = '\njobs:\n  quality:\n    runs-on: ubuntu-24.04\n  tests:\n    runs-on: macos-15\n  required:\n    needs: ["quality", "tests"]\n    if: ${{ always() }}\n'


class RequiredTests(unittest.TestCase):
    def test_all_success_passes(self):
        expected = API["expected_jobs"](WORKFLOW)
        API["require_success"]({name: {"result": "success"} for name in expected}, expected)

    def test_failed_dependency_fails(self):
        with self.assertRaisesRegex(ValueError, "did not succeed"):
            API["require_success"]({"quality": {"result": "success"}, "tests": {"result": "failure"}}, {"quality", "tests"})

    def test_cancelled_dependency_fails(self):
        with self.assertRaisesRegex(ValueError, "did not succeed"):
            API["require_success"]({"quality": {"result": "success"}, "tests": {"result": "cancelled"}}, {"quality", "tests"})

    def test_skipped_dependency_fails(self):
        with self.assertRaisesRegex(ValueError, "did not succeed"):
            API["require_success"]({"quality": {"result": "success"}, "tests": {"result": "skipped"}}, {"quality", "tests"})

    def test_missing_empty_or_undeclared_dependencies_fail(self):
        expected = API["expected_jobs"](WORKFLOW)
        for result in [{}, {"quality": {"result": "success"}}, {"quality": {"result": "success"}, "tests": {"result": "success"}, "extra": {"result": "success"}}]:
            with self.assertRaisesRegex(ValueError, "Missing, unexpected or empty"):
                API["require_success"](result, expected)
        missing_needs = WORKFLOW.replace('["quality", "tests"]', '["quality"]')
        with self.assertRaisesRegex(ValueError, "every other declared CI job"):
            API["expected_jobs"](missing_needs)
