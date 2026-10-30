#!/usr/bin/env python3
"""Validate source without importing scripts or writing bytecode into the checkout."""

import argparse
import ast
import json
import os
from pathlib import Path
import plistlib
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def check_file(path: Path, *, whitespace: bool = False) -> None:
    if not path.is_file():
        return  # A deleted source file has no contents to validate.
    if path.suffix == ".py":
        ast.parse(path.read_text(), filename=str(path))
    elif path.suffix == ".sh":
        subprocess.run(["bash", "-n", str(path)], check=True)
    elif path.suffix == ".plist":
        with path.open("rb") as source:
            plistlib.load(source)
    elif path.suffix == ".json":
        json.loads(path.read_text())
    if whitespace and path.suffix in {".py", ".sh", ".swift", ".md", ".yml", ".yaml", ".json", ".plist"}:
        for number, line in enumerate(path.read_text().splitlines(), 1):
            if line.rstrip() != line or line.startswith(("<<<<<<< ", ">>>>>>> ")):
                raise ValueError(f"{path}:{number}: trailing whitespace or conflict marker")


def trim_logs(directory: Path) -> None:
    if directory.resolve().is_relative_to(ROOT):
        raise ValueError("Diagnostic logs must stay outside the repository")
    limit = 2 * 1024 * 1024
    for path in directory.glob("*.log"):
        size = path.stat().st_size
        if size > limit:
            header = f"[Retained final bytes; original log size: {size} bytes]\n".encode()
            with path.open("rb") as source:
                source.seek(-(limit - len(header)), 2)
                tail = source.read()
            path.write_bytes(header + tail)
    print("PASS retained diagnostic logs capped at 2 MiB each")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--test-log", type=Path)
    parser.add_argument("--manifest-json", type=Path)
    parser.add_argument("--trim-logs", type=Path)
    args = parser.parse_args()
    if args.trim_logs:
        if args.test_log or args.manifest_json:
            parser.error("--trim-logs cannot be combined with test validation")
        trim_logs(args.trim_logs)
        return
    if args.test_log or args.manifest_json:
        if not (args.test_log and args.manifest_json):
            parser.error("--test-log and --manifest-json must be supplied together")
        manifest = json.loads(args.manifest_json.read_text())
        expected = {"EventBridgeTests", "SessionStateTests", "PetTests", "NotchPetTests"}
        actual = {target["name"] for target in manifest["targets"] if target["type"] == "test"}
        if not expected <= actual:
            raise ValueError(f"Missing Swift test targets: {sorted(expected - actual)}")
        runs = re.findall(r"Test run with ([1-9][0-9]*) tests?[^\n]*passed after", args.test_log.read_text())
        if not runs:
            raise ValueError("No successful nonzero Swift Testing run in the test log")
        print(f"PASS {len(actual)} test targets; {sum(map(int, runs))} Swift Testing tests passed")
        return

    files = subprocess.check_output(
        ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"], cwd=ROOT
    ).decode().split("\0")
    changed = set(subprocess.check_output(["git", "diff", "--name-only", "-z", "HEAD"], cwd=ROOT).decode().split("\0"))
    changed.update(subprocess.check_output(["git", "ls-files", "-z", "--others", "--exclude-standard"], cwd=ROOT).decode().split("\0"))
    base = os.environ.get("CI_BASE_SHA", "")
    if base and not re.fullmatch(r"0+", base):
        if not re.fullmatch(r"[0-9a-f]{40}", base):
            raise ValueError("CI_BASE_SHA must be a full commit SHA")
        subprocess.run(["git", "diff", "--check", base, "HEAD"], cwd=ROOT, check=True)
        changed.update(subprocess.check_output(["git", "diff", "--name-only", "-z", base, "HEAD"], cwd=ROOT).decode().split("\0"))
    subprocess.run(["git", "diff", "--check"], cwd=ROOT, check=True)
    for name in sorted(set(files) - {""}):
        check_file(ROOT / name, whitespace=name in changed)
    print("PASS source syntax, JSON/plist parsing, and changed-source whitespace")


if __name__ == "__main__":
    main()
