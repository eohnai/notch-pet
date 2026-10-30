import copy
import json
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest

CHECKER = Path(__file__).with_name("check-coverage.py")
API = runpy.run_path(str(CHECKER))
ROOT = API["ROOT"]
REPORT = {"type": "llvm.coverage.json.export", "data": [{"files": [
    {"filename": str(ROOT / "Sources" / module / "Example.swift"),
     "summary": {"lines": {"count": 10, "covered": 0}}}
    for module in sorted(API["MODULES"])
]}]}


class CoverageTests(unittest.TestCase):
    def test_complete_report_has_no_arbitrary_percentage_floor(self):
        summary = API["summarize"](REPORT, ROOT)
        self.assertEqual(set(summary), API["MODULES"])
        self.assertTrue(all(value["covered"] == 0 for value in summary.values()))

    def test_missing_module_is_rejected(self):
        report = copy.deepcopy(REPORT)
        report["data"][0]["files"].pop()
        with self.assertRaisesRegex(ValueError, "Missing or empty production coverage"):
            API["summarize"](report, ROOT)

    def test_empty_export_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Missing LLVM coverage"):
            API["summarize"]({"type": "llvm.coverage.json.export", "data": []}, ROOT)

    def test_invalid_line_counters_are_rejected(self):
        report = copy.deepcopy(REPORT)
        report["data"][0]["files"][0]["summary"]["lines"]["covered"] = 11
        with self.assertRaisesRegex(ValueError, "Invalid line counters"):
            API["summarize"](report, ROOT)

    def test_cli_rejects_missing_and_malformed_reports(self):
        with tempfile.TemporaryDirectory(prefix="notch-pet-coverage-", dir=tempfile.gettempdir()) as directory:
            path = Path(directory) / "report.json"
            missing = subprocess.run([sys.executable, "-B", str(CHECKER), "--report", str(path)], capture_output=True)
            self.assertNotEqual(missing.returncode, 0)
            path.write_text("{invalid JSON")
            malformed = subprocess.run([sys.executable, "-B", str(CHECKER), "--report", str(path)], capture_output=True)
            self.assertNotEqual(malformed.returncode, 0)
            path.write_text(json.dumps(REPORT))
            valid = subprocess.run([sys.executable, "-B", str(CHECKER), "--report", str(path)], capture_output=True)
            self.assertEqual(valid.returncode, 0, valid.stderr.decode())
