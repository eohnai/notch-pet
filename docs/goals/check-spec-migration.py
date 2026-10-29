#!/usr/bin/env python3
"""Frozen checks for docs/goals/migrate-implemented-specs.md. Do not edit during the goal run.

Run from the repository root: python3 docs/goals/check-spec-migration.py
Prints one PASS/FAIL line per criterion and exits 0 only when all pass.
"""
import hashlib
import re
import subprocess
import sys
from pathlib import Path

BASE = "1b992b3"
SOURCE = "docs/specs/notch-companion.md"
BRIDGE = "docs/specs/sessions/observation-bridge.md"
PROTECTED_DIFF_SHA = "cc5d55749822b15b32ca282670c1582d0384abc4"
PROTECTED = ["Sources", "Tests", "Package.swift", "docs/goals/notch-agent-limits-log.md"]

SPECS = {
    "docs/specs/sessions/session-state.md": "observation-bridge",
    "docs/specs/sessions/integration-health.md": "observation-bridge",
    "docs/specs/notch/session-island.md": "sessions/session-state",
    "docs/specs/usage/codex-allowance.md": "notch/session-island",
    "docs/specs/usage/claude-allowance.md": "codex-allowance",
}
# Task line prefixes that must move to each new spec. Every other original task stays where it was.
MOVES = {
    "docs/specs/sessions/session-state.md": ["- [x] Add the shared session store"],
    "docs/specs/sessions/integration-health.md": ["- [ ] I2a:", "- [ ] I2b:", "- [ ] I2c:"],
    "docs/specs/notch/session-island.md": ["- [ ] I1:", "- [ ] N3:", "- [ ] N4:", "- [ ] N5:"],
    "docs/specs/usage/codex-allowance.md": [
        "- [x] Verify both providers' usage sources", "- [ ] U1:", "- [x] U3a:", "- [x] U3b1:",
        "- [ ] U3b2:", "- [ ] U5:"],
    "docs/specs/usage/claude-allowance.md": [
        "- [x] U2a:", "- [ ] U2b:", "- [x] U2c1:", "- [x] U2c2:", "- [ ] U2c3:"],
}
STALE_PHRASES = [
    "Do not migrate specs or decision records into new folders",
    "Keep the existing single specification",
    "honoring the user's single-spec preference",
    "its implementation has not started",
]
GAP_LABELS = [
    "Usage socket providers", "Stale usage socket recovery", "Usage receiver health",
    "Usage source lifetime", "Usage service ownership",
]
AREA_LINKS = {
    "docs/specs/sessions/area.md": ["session-state.md", "integration-health.md"],
    "docs/specs/notch/area.md": ["session-island.md"],
    "docs/specs/usage/area.md": ["codex-allowance.md", "claude-allowance.md"],
}
TASK = re.compile(r"^- \[( |x)\] ")
results = []


def check(name, ok, detail=""):
    results.append(ok)
    print(f"{'PASS' if ok else 'FAIL'} {name}" + (f" -- {detail}" if detail and not ok else ""))


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True).stdout


def read(path):
    p = Path(path)
    return p.read_text() if p.exists() else ""


def tasks(text):
    return [line for line in text.splitlines() if TASK.match(line)]


def slug(heading):
    s = re.sub(r"[^\w\- ]", "", heading.strip().lower())
    return s.replace(" ", "-")


# C1: old single-spec and I2 statements are gone or marked superseded on the same line.
source = read(SOURCE)
bad = [p for p in STALE_PHRASES for line in source.splitlines() if p in line and "uperseded" not in line]
check("C1 stale source-spec statements superseded", not bad, "; ".join(bad))

# C2: the five specs exist with the template sections, correct Needs line, and no done status.
problems = []
for path, needs in SPECS.items():
    text = read(path)
    if not text:
        problems.append(f"{path} missing")
        continue
    for heading in ["## Goal", "## Done when", "## Out of scope", "## Verify", "## Decisions",
                    "## My calls", "## Tasks"]:
        if not re.search(rf"^{heading}\s*$", text, re.M):
            problems.append(f"{path} lacks {heading}")
    if not re.search(r"^## .*[Ee]vidence", text, re.M):
        problems.append(f"{path} lacks an evidence section")
    if not re.search(rf"^Needs: {re.escape(needs)}\s*$", text, re.M):
        problems.append(f"{path} needs 'Needs: {needs}'")
    if re.search(r"^Status: done", text, re.M):
        problems.append(f"{path} is marked done")
check("C2 five specs exist with required sections", not problems, "; ".join(problems))

# C3: every original task line exists exactly once, unchanged, in its required file.
original = tasks(git("show", f"{BASE}:{SOURCE}")) + tasks(git("show", f"{BASE}:{BRIDGE}"))
spec_files = sorted(str(p) for p in Path("docs/specs").rglob("*.md"))
where = {}
for f in spec_files:
    for line in tasks(read(f)):
        where.setdefault(line, []).append(f)
problems = []
for line in original:
    found = where.get(line, [])
    target = next((f for f, prefixes in MOVES.items() if any(line.startswith(p) for p in prefixes)), None)
    if target is None:
        target = BRIDGE if line in tasks(git("show", f"{BASE}:{BRIDGE}")) else SOURCE
    if found != [target]:
        problems.append(f"{line[:40]!r} found in {found or 'nowhere'}, expected {target}")
moved = sum(len(v) for v in MOVES.values())
check(f"C3 {len(original)} original task lines preserved, {moved} moved to new specs",
      not problems and len(original) == 66, "; ".join(problems[:6]) + (" ..." if len(problems) > 6 else ""))

# C4: added task lines are unchecked, only in the five new specs, at most nine tasks per spec.
problems = []
for line, files in where.items():
    if line in original:
        continue
    for f in files:
        if f not in SPECS:
            problems.append(f"new task in {f}: {line[:40]!r}")
        elif line.startswith("- [x]"):
            problems.append(f"new task is checked in {f}: {line[:40]!r}")
for path in SPECS:
    count = len(tasks(read(path)))
    if count > 9:
        problems.append(f"{path} has {count} tasks")
check("C4 new tasks unchecked and within size", not problems, "; ".join(problems))

# C5: five open gaps recorded in claude-allowance; codex-allowance records the view-owned refresh.
claude = read("docs/specs/usage/claude-allowance.md")
problems = []
for label in GAP_LABELS:
    lines = [l for l in claude.splitlines() if label in l]
    if not any("open" in l.lower() for l in lines):
        problems.append(f"'{label}' not on a line marked open")
    if any("accepted" in l.lower() for l in lines):
        problems.append(f"'{label}' marked accepted")
codex = read("docs/specs/usage/codex-allowance.md")
if not ("NotchUsageView" in codex and "0002" in codex):
    problems.append("codex-allowance does not record NotchUsageView refresh against decision 0002")
check("C5 open usage decisions recorded", not problems, "; ".join(problems))

# C6: each moved task ID is cited outside its task line; goal-log evidence is cited.
problems = []
for path, prefixes in MOVES.items():
    text = read(path)
    prose = "\n".join(l for l in text.splitlines() if not TASK.match(l))
    for p in prefixes:
        m = re.match(r"- \[.\] (\w+):", p)
        if m and not re.search(rf"\b{m.group(1)}\b", prose):
            problems.append(f"{m.group(1)} has no evidence text in {path}")
for path in ["docs/specs/notch/session-island.md", "docs/specs/usage/codex-allowance.md"]:
    if "notch-agent-limits-log.md" not in read(path):
        problems.append(f"{path} does not cite notch-agent-limits-log.md")
check("C6 evidence cited for moved tasks", not problems, "; ".join(problems))

# C7: area indexes and the source spec link the new specs.
problems = []
for area, names in AREA_LINKS.items():
    for name in names:
        if f"]({name}" not in read(area):
            problems.append(f"{area} lacks link to {name}")
for path in SPECS:
    rel = path.removeprefix("docs/specs/")
    if f"]({rel}" not in source:
        problems.append(f"{SOURCE} lacks link to {rel}")
check("C7 area indexes and source spec link new specs", not problems, "; ".join(problems))

# C8: historical evidence in the source spec is kept (lines may be added, not removed).
base_lines = git("show", f"{BASE}:{SOURCE}").splitlines()
start = base_lines.index("## Coverage check")
keep, skipping = [], False
for line in base_lines[start:]:
    if line.startswith("### Revised acceptance coverage"):
        skipping = True
    elif line.startswith("## Verify"):
        skipping = False
    if not skipping and line.strip():
        keep.append(line)
current = set(source.splitlines())
missing = [l for l in keep if l not in current]
check(f"C8 {len(keep)} historical source-spec lines kept", not missing,
      f"{len(missing)} missing, first: {missing[0][:60]!r}" if missing else "")

# C9: local Markdown links and anchors resolve in specs and STATUS.md.
broken = []
for f in spec_files + ["docs/STATUS.md"]:
    for target in re.findall(r"\]\(([^)\s]+)\)", read(f)):
        if re.match(r"[a-z]+:", target):
            continue
        file_part, _, anchor = target.partition("#")
        dest = (Path(f).parent / file_part).resolve() if file_part else Path(f).resolve()
        if not dest.exists():
            broken.append(f"{f} -> {target}")
        elif anchor and dest.suffix == ".md":
            anchors = {slug(h) for h in re.findall(r"^#+ (.+)$", dest.read_text(), re.M)}
            if anchor not in anchors:
                broken.append(f"{f} -> {target}")
check("C9 local links resolve", not broken, "; ".join(broken[:6]))

# C10: whitespace check and protected files unchanged; existing decisions unchanged.
problems = []
if subprocess.run(["git", "diff", "--check"], capture_output=True).returncode != 0:
    problems.append("git diff --check failed")
sha = hashlib.sha1(subprocess.run(["git", "diff", "--", *PROTECTED], capture_output=True).stdout).hexdigest()
if sha != PROTECTED_DIFF_SHA:
    problems.append("protected source/test/goal-log diff changed")
if git("status", "--porcelain", "--untracked-files=all", "--", "Sources", "Tests").count("??"):
    problems.append("untracked files in Sources or Tests")
if git("diff", "--name-only", "--", "docs/decisions", "docs/ARCHITECTURE.md", "README.md", "docs/contracts", "docs/notes").strip():
    problems.append("existing decisions, architecture, README, contracts or notes changed")
for f in git("ls-files", "--others", "--exclude-standard", "--", "docs/decisions").split():
    if "Status: proposed" not in read(f):
        problems.append(f"{f} is not a proposed decision")
check("C10 scope and whitespace", not problems, "; ".join(problems))

passed = sum(results)
print(f"{passed}/{len(results)} criteria pass")
sys.exit(0 if passed == len(results) else 1)
