#!/usr/bin/env python3
"""Fail closed unless every job declared by the workflow has succeeded."""

import argparse
import json
import os
from pathlib import Path
import re


def expected_jobs(workflow: str) -> set[str]:
    # The needs list is deliberately JSON-compatible YAML. Refuse other syntax,
    # rather than pretending this small checker is a general-purpose YAML parser.
    jobs = workflow.split("\njobs:\n", 1)[1]
    declared = re.findall(r"^  ([A-Za-z_][A-Za-z0-9_-]*):\s*$", jobs, re.MULTILINE)
    gate = re.search(r"^  required:\s*\n((?:^ {4,}.*\n|^\s*\n)*)", jobs, re.MULTILINE)
    needs = re.search(r"^    needs: (\[[^\n]*\])$", gate[1] if gate else "", re.MULTILINE)
    if not needs:
        raise ValueError("Required must declare needs as an explicit JSON-compatible list")
    expected = json.loads(needs[1])
    if not isinstance(expected, list) or not expected or any(type(name) is not str for name in expected):
        raise ValueError("Required needs must be a nonempty list of job IDs")
    if len(set(declared)) != len(declared) or len(set(expected)) != len(expected):
        raise ValueError("Duplicate workflow job or Required dependency")
    if set(expected) != set(declared) - {"required"}:
        raise ValueError("Required needs must include every other declared CI job")
    return set(expected)


def require_success(results: dict, expected: set[str]) -> None:
    if not expected or not isinstance(results, dict) or set(results) != expected:
        raise ValueError("Missing, unexpected or empty job results")
    failures = {name: result.get("result") if isinstance(result, dict) else "invalid"
                for name, result in results.items() if not isinstance(result, dict) or result.get("result") != "success"}
    if failures:
        raise ValueError(f"Required dependencies did not succeed: {failures}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workflow", type=Path, default=Path(__file__).resolve().parents[2] / ".github/workflows/ci.yml")
    args = parser.parse_args()
    expected = expected_jobs(args.workflow.read_text())
    require_success(json.loads(os.environ["CI_JOB_RESULTS"]), expected)
    print("PASS required jobs: " + ", ".join(sorted(expected)))


if __name__ == "__main__":
    main()
