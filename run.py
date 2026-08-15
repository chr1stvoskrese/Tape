#!/usr/bin/env python3
"""Open, build, install, and launch Tape in an iPhone Simulator.

Run from the repository root on macOS:
    python3 run.py

No third-party Python packages are required.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROJECT = ROOT / "Tape.xcodeproj"
SCHEME = "Tape"
BUNDLE_ID = "chr1stvoskrese.Tape"
DERIVED_DATA = ROOT / ".build"
APP_PATH = DERIVED_DATA / "Build" / "Products" / "Debug-iphonesimulator" / "Tape.app"


def run(*args: str, check: bool = True, capture_output: bool = False) -> subprocess.CompletedProcess[str]:
    print("$", " ".join(args))
    return subprocess.run(
        args,
        check=check,
        text=True,
        capture_output=capture_output,
    )


def command_exists(name: str) -> bool:
    return shutil.which(name) is not None


def choose_simulator() -> tuple[str, str]:
    result = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "--json"],
        check=True,
        capture_output=True,
        text=True,
    )
    payload = json.loads(result.stdout)

    preferred = {
        "iPhone SE (3rd generation)": 0,
        "iPhone 13 mini": 1,
        "iPhone 12 mini": 2,
        "iPhone 13": 3,
        "iPhone 14": 4,
        "iPhone 15": 5,
        "iPhone 16e": 6,
        "iPhone 16": 7,
    }

    candidates: list[tuple[str, str]] = []
    for runtime_devices in payload.get("devices", {}).values():
        for device in runtime_devices:
            if device.get("isAvailable") is not True:
                continue
            name = device.get("name", "")
            if not name.startswith("iPhone"):
                continue
            udid = device.get("udid")
            if udid:
                candidates.append((name, udid))

    if not candidates:
        raise RuntimeError("No available iPhone simulator was found.")

    candidates.sort(key=lambda item: (preferred.get(item[0], 100), item[0]))
    return candidates[0]


def boot_simulator(udid: str, name: str) -> None:
    state = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "booted"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout

    if udid not in state:
        try:
            run("xcrun", "simctl", "boot", udid)
        except subprocess.CalledProcessError:
            state = subprocess.run(
                ["xcrun", "simctl", "list", "devices", "booted"],
                check=True,
                capture_output=True,
                text=True,
            ).stdout
            if udid not in state:
                raise

    run("xcrun", "simctl", "bootstatus", udid, "-b")
    run("open", "-a", "Simulator")
    print(f"Simulator: {name}")


def uninstall_previous(udid: str) -> None:
    result = subprocess.run(
        ["xcrun", "simctl", "uninstall", udid, BUNDLE_ID],
        text=True,
        capture_output=True,
    )
    if result.returncode == 0:
        print(f"Removed previous {BUNDLE_ID} installation.")


def main() -> int:
    if sys.platform != "darwin":
        print("Tape's automatic Xcode/Simulator launcher requires macOS.", file=sys.stderr)
        return 2

    for required in ("xcodebuild", "xcrun", "open"):
        if not command_exists(required):
            print(f"Required command not found: {required}", file=sys.stderr)
            return 2

    if not PROJECT.exists():
        print(f"Xcode project not found: {PROJECT}", file=sys.stderr)
        return 2

    name, udid = choose_simulator()

    print("\nTape developer launcher")
    print("=======================")
    print(f"Project : {PROJECT}")
    print(f"Target  : {name}")

    run("open", "-a", "Xcode", str(PROJECT))
    boot_simulator(udid, name)
    uninstall_previous(udid)

    if DERIVED_DATA.exists():
        shutil.rmtree(DERIVED_DATA)
    DERIVED_DATA.mkdir(parents=True, exist_ok=True)

    run(
        "xcodebuild",
        "-project",
        str(PROJECT),
        "-scheme",
        SCHEME,
        "-configuration",
        "Debug",
        "-sdk",
        "iphonesimulator",
        "-destination",
        f"platform=iOS Simulator,id={udid}",
        "-destination-timeout",
        "60",
        "-derivedDataPath",
        str(DERIVED_DATA),
        "build",
    )

    if not APP_PATH.exists():
        print(f"Built app not found at {APP_PATH}", file=sys.stderr)
        return 1

    run("xcrun", "simctl", "install", udid, str(APP_PATH))
    time.sleep(0.5)
    launch = run(
        "xcrun",
        "simctl",
        "launch",
        udid,
        BUNDLE_ID,
        capture_output=True,
    )

    launch_output = (launch.stdout or launch.stderr or "").strip()
    print(f"\nLaunch result: {launch_output or 'ok'}")
    print("Tape is running in Simulator.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
