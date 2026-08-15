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


def run(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    print("$", " ".join(args))
    return subprocess.run(args, check=check, text=True)


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

    # Prefer a small/basic iPhone, but accept whatever is installed.
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
            # Another process (often Simulator itself) may have booted it
            # between the state check and the boot command.
            state = subprocess.run(
                ["xcrun", "simctl", "list", "devices", "booted"],
                check=True,
                capture_output=True,
                text=True,
            ).stdout
            if udid not in state:
                raise
        time.sleep(2)

    run("open", "-a", "Simulator")
    print(f"Simulator: {name}")


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
        "-derivedDataPath",
        str(DERIVED_DATA),
        "build",
    )

    if not APP_PATH.exists():
        print(f"Built app not found at {APP_PATH}", file=sys.stderr)
        return 1

    run("xcrun", "simctl", "install", udid, str(APP_PATH))
    run("xcrun", "simctl", "launch", udid, BUNDLE_ID)

    print("\nTape is running in Simulator.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
