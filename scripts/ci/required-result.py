#!/usr/bin/env python3
"""Accept only the exact five successful foundation job results."""

from __future__ import annotations

import json
import os
import sys

MAX_INPUT = 16 * 1024
JOBS = {"workflow": "Workflow", "tests": "Tests", "build": "Build",
        "contract": "Contract", "helper": "Helper"}
KNOWN_RESULTS = {"success", "failure", "cancelled", "skipped"}


def unique_jobs(pairs: list[tuple[str, object]]) -> dict:
    result: dict = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate job")
        result[key] = value
    return result


def required_result(raw: str | None) -> tuple[bool, list[str]]:
    results: dict = {}
    reason = ""
    try:
        if raw is None or not raw.strip() or len(raw.encode("utf-8")) > MAX_INPUT:
            raise ValueError("missing or oversized results")
        value = json.loads(raw, object_pairs_hook=unique_jobs)
        if type(value) is not dict:
            raise ValueError("expected object")
        results = value
    except (ValueError, RecursionError):
        reason = "missing or malformed job results"
    if not reason and results.keys() != JOBS.keys():
        reason = "unexpected job set"
    labels: list[str] = []
    all_success = not reason
    for key, name in JOBS.items():
        if key not in results:
            label = "missing"
        elif type(results[key]) is not str:
            label = "malformed"
        elif results[key] in KNOWN_RESULTS:
            label = results[key]
        else:
            label = "unknown"
        all_success = all_success and label == "success"
        labels.append(f"{name}: {label}")
    labels.append("Required: success" if all_success else "Required: failure")
    if reason:
        labels.append("Reason: " + reason)
    return all_success, labels


def main() -> int:
    success, lines = required_result(os.environ.get("CI_JOB_RESULTS"))
    print("\n".join(lines))
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
