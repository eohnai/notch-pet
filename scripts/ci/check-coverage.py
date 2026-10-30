#!/usr/bin/env python3
"""Export LLVM coverage and require real production-source data for each tested module."""

import argparse
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
MODULES = {"Pet", "EventBridge", "SessionState", "NotchPet"}


def summarize(report: dict, root: Path) -> dict:
    if report.get("type") != "llvm.coverage.json.export" or not report.get("data"):
        raise ValueError("Missing LLVM coverage export data")
    modules = {name: {"files": 0, "lines": 0, "covered": 0} for name in sorted(MODULES)}
    seen = set()
    for chunk in report["data"]:
        for item in chunk["files"]:
            path = Path(item["filename"]).resolve()
            if not path.is_relative_to(root / "Sources"):
                continue
            relative = path.relative_to(root / "Sources")
            if relative.parts[0] not in modules:
                continue
            if path in seen:
                raise ValueError(f"Duplicate production coverage entry: {relative}")
            seen.add(path)
            counts = item["summary"]["lines"]
            count, covered = counts["count"], counts["covered"]
            if type(count) is not int or type(covered) is not int or not 0 <= covered <= count:
                raise ValueError(f"Invalid line counters: {relative}")
            module = modules[relative.parts[0]]
            module["files"] += 1
            module["lines"] += count
            module["covered"] += covered
    for name, counts in modules.items():
        if counts["files"] == 0 or counts["lines"] == 0:
            raise ValueError(f"Missing or empty production coverage for {name}")
    return modules


def collect(scratch: Path, output: Path, root: Path) -> dict:
    if output.resolve().is_relative_to(root):
        raise ValueError("Coverage output must stay outside the repository")
    profiles = list(scratch.rglob("default.profdata"))
    objects = sorted(path for path in scratch.glob("**/*.xctest/Contents/MacOS/*") if path.is_file())
    if len(profiles) != 1 or not objects:
        raise ValueError("Expected exactly one merged profile and at least one macOS test executable")
    output.mkdir(parents=True, exist_ok=True)
    command = ["xcrun", "llvm-cov", "export", str(objects[0]), "-instr-profile", str(profiles[0])]
    for binary in objects[1:]:
        command.extend(["-object", str(binary)])
    report_path = output / "coverage.json"
    with report_path.open("w") as destination:
        subprocess.run(command, stdout=destination, check=True)
    modules = summarize(json.loads(report_path.read_text()), root)
    metadata = {
        "revision": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
        "dirty": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=root)),
        "swift": subprocess.check_output(["swift", "--version"], text=True).strip(),
        "xcode": subprocess.check_output(["xcodebuild", "-version"], text=True).strip(),
        "modules": modules,
        "NotchPetHook": "unmeasured: helper process checks do not collect helper coverage",
    }
    (output / "summary.json").write_text(json.dumps(metadata, indent=2) + "\n")
    lines = ["# Swift production coverage", "", f"Revision: `{metadata['revision']}`; dirty: {metadata['dirty']}", "",
             "| Module | Files | Covered / executable lines | Coverage |", "|---|---:|---:|---:|"]
    for name, counts in modules.items():
        lines.append(f"| {name} | {counts['files']} | {counts['covered']} / {counts['lines']} | "
                     f"{100 * counts['covered'] / counts['lines']:.2f}% |")
    lines.extend(["", "NotchPetHook coverage: unmeasured. No minimum coverage percentage is enforced.", ""])
    (output / "summary.md").write_text("\n".join(lines))
    return modules


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path, help="Validate an existing LLVM JSON export")
    parser.add_argument("--scratch-path", type=Path)
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    if args.report:
        if args.scratch_path or args.output_dir:
            parser.error("--report cannot be combined with collection options")
        modules = summarize(json.loads(args.report.read_text()), ROOT)
    else:
        if not (args.scratch_path and args.output_dir):
            parser.error("Supply --scratch-path and --output-dir, or --report")
        modules = collect(args.scratch_path, args.output_dir, ROOT)
    print("PASS production coverage for " + ", ".join(modules))


if __name__ == "__main__":
    main()
