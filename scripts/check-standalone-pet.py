#!/usr/bin/env python3
"""Check the actual pet app with disposable preferences and window-only captures.

Never quits an existing app instance or changes agent configuration. Requires a
GUI session and screen-capture access. Fixtures and generated probes stay outside
the repository. A capture must also be visually inspected before acceptance.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import time
import uuid


CONTROL = r'''
import AppKit
import CoreGraphics
let args = CommandLine.arguments
switch args[1] {
case "focus":
    print(NSWorkspace.shared.frontmostApplication?.processIdentifier ?? -1)
case "quit":
    guard let pid = Int32(args[2]), let app = NSRunningApplication(processIdentifier: pid),
          app.terminate() else { exit(1) }
case "windows":
    let pid = Int32(args[2])!
    let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], 0)
        as? [[String: Any]] ?? []
    let owned = windows.filter { ($0[kCGWindowOwnerPID as String] as? Int32) == pid }
    print(String(data: try JSONSerialization.data(withJSONObject: owned), encoding: .utf8)!)
default: exit(2)
}
'''


def run_case(app: Path, root: Path, control: Path, suite: str, name: str) -> dict:
    case = root / name
    case.mkdir()
    (case / "codex").mkdir()
    (case / "claude").mkdir()
    env = {key: value for key, value in os.environ.items()
           if key in {"PATH", "TMPDIR", "DEVELOPER_DIR"}}
    env.update(NOTCH_PET_PREFERENCES_SUITE=suite,
               NOTCH_PET_EVIDENCE_DIR=str(case),
               CODEX_HOME=str(case / "codex"), CLAUDE_CONFIG_DIR=str(case / "claude"))
    focus_before = int(subprocess.check_output([str(control), "focus"], text=True))
    executable = app / "Contents/MacOS/NotchPet"
    with (case / "stdout.txt").open("w") as out, (case / "stderr.txt").open("w") as err:
        process = subprocess.Popen([str(executable)], env=env, stdout=out, stderr=err)
        try:
            deadline = time.monotonic() + 20
            evidence_file = case / "pet.json"
            while not evidence_file.exists() and time.monotonic() < deadline:
                assert process.poll() is None, f"{name}: app exited before evidence"
                time.sleep(0.1)
            assert evidence_file.exists(), f"{name}: no evidence from normal app startup"
            evidence = json.loads(evidence_file.read_text())
            assert evidence["pid"] == process.pid
            assert Path(evidence["executable"]).resolve() == executable.resolve()
            assert evidence["petVisible"] and evidence["artworkLoaded"]
            assert evidence["presentation"] == "pet" and evidence["agentServicesEnabled"] is False
            assert evidence["size"] >= 64 and evidence["size"] <= 256
            assert set(evidence["serviceStarts"]) == {
                "eventReceiver", "usageReceiver", "providerProcess", "configurationProbe", "agentRefresh"
            }
            assert all(value == 0 for value in evidence["serviceStarts"].values())
            windows = json.loads(subprocess.check_output(
                [str(control), "windows", str(process.pid)], text=True))
            (case / "windows.json").write_text(json.dumps(windows, indent=2))
            pet = [w for w in windows if w["kCGWindowNumber"] == evidence["windowNumber"]]
            assert len(pet) == 1, f"{name}: pet window not independently observed"
            bounds = pet[0]["kCGWindowBounds"]
            assert abs(bounds["Width"] - evidence["size"]) <= 1
            assert abs(bounds["Height"] - evidence["size"]) <= 1
            capture = case / "pet.png"
            subprocess.run(["/usr/sbin/screencapture", "-x", "-o", "-l",
                            str(evidence["windowNumber"]), str(capture)], check=True, timeout=15)
            assert capture.exists() and capture.stat().st_size > 1024, f"{name}: invalid capture"
            focus_after = int(subprocess.check_output([str(control), "focus"], text=True))
            assert focus_before == focus_after and focus_before != process.pid, f"{name}: focus changed"
            assert evidence["focusBefore"] == evidence["focusAfter"] != process.pid
            evidence["independentFocusBefore"] = focus_before
            evidence["independentFocusAfter"] = focus_after
            (case / "verified.json").write_text(json.dumps(evidence, indent=2))
            subprocess.run([str(control), "quit", str(process.pid)], check=True, timeout=15)
            process.wait(timeout=15)
            assert process.returncode == 0, f"{name}: Quit failed"
            final = json.loads(evidence_file.read_text())
            assert final["phase"] == "terminated", f"{name}: normal Quit lifecycle not observed"
            assert all(value == 0 for value in final["serviceStarts"].values())
            return evidence
        finally:
            if process.poll() is None:
                # Target only the instance this check created.
                subprocess.run([str(control), "quit", str(process.pid)], timeout=10)
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.terminate()
                    process.wait(timeout=10)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--app", required=True, type=Path)
    parser.add_argument("--artifacts", required=True, type=Path)
    args = parser.parse_args()
    app = args.app.resolve()
    root = args.artifacts.resolve() / uuid.uuid4().hex
    repo = Path(__file__).resolve().parents[1]
    assert not root.is_relative_to(repo), "artifacts must stay outside the repository"
    resource = app / "Contents/Resources/NotchPet_Pet.bundle"
    assert resource.is_dir(), "packaged Pet resource bundle missing"
    assert list(resource.rglob("white-lionhead-idle.png")), "packaged rabbit missing"
    root.mkdir(parents=True)
    (root / "control.swift").write_text(CONTROL)
    control = root / "control"
    subprocess.run(["/usr/bin/swiftc", str(root / "control.swift"), "-o", str(control)],
                   check=True, timeout=120)
    suite = "local.notchpet.verify." + uuid.uuid4().hex
    try:
        missing = run_case(app, root, control, suite, "missing-preferences")
        assert missing["size"] == 120, "missing preferences must use default size"
        subprocess.run(["/usr/bin/defaults", "write", suite, "pet.size", "-float", "180"], check=True)
        saved = run_case(app, root, control, suite, "saved-size")
        restored = run_case(app, root, control, suite, "saved-size-relaunch")
        assert saved["size"] == restored["size"] == 180, "saved size did not survive Quit/relaunch"
        subprocess.run(["/usr/bin/defaults", "write", suite, "pet.size", "-string", "invalid"], check=True)
        invalid = run_case(app, root, control, suite, "invalid-preferences")
        assert invalid["size"] == 120, "invalid preferences must use default size"
        checks = ["visible rabbit without agent panels/warnings", "usable default size",
                  "saved size survives Quit/relaunch", "invalid size fallback",
                  "zero production agent-service starts", "keyboard focus preserved"]
        report = {"checks": checks, "passed": 6, "total": 6, "artifacts": str(root),
                  "visualInspectionRequired": True,
                  "sizeSeedMethod": "isolated UserDefaults domain; setter covered by Swift tests"}
        (root / "result.json").write_text(json.dumps(report, indent=2))
        for check in checks:
            print("PASS:", check)
        print("6/6 real-app checks passed; inspect captures:", root)
    finally:
        subprocess.run(["/usr/bin/defaults", "delete", suite], capture_output=True)


if __name__ == "__main__":
    main()
