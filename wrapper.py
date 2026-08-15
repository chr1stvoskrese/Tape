#!/usr/bin/env python3
"""Copy the complete Tape source tree into the macOS clipboard."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

IOS_PROMPT = r'''Ты — senior iOS-разработчик и code reviewer с большим опытом Swift, SwiftUI, UIKit, Xcode и iOS SDK.
Работай как инженер, который отвечает за результат: сначала анализируй архитектуру и зависимости проекта целиком, затем исправляй первопричины, а не маскируй ошибки.

Контекст проекта:
- приложение: Tape
- платформа: iOS
- текущая среда разработки: macOS Sequoia 15.7.9
- целевой SDK: iOS 26
- сборка проекта запускается через `python3 run.py`

Твоя задача — внимательно изучить весь переданный исходный код проекта, найти баги, проблемы сборки, проблемы совместимости с современным iOS SDK, ошибки Swift/SwiftUI/UIKit, проблемы состояния, UI/UX и архитектуры.
Не придумывай отсутствующие файлы или API. Проверяй взаимосвязи между файлами и предлагай конкретные исправления с готовым кодом.
'''

# Source/code files that are useful to an iOS engineer reviewing the whole app.
CODE_EXTENSIONS = {
    ".swift",
    ".m",
    ".mm",
    ".h",
    ".hpp",
    ".c",
    ".cc",
    ".cpp",
    ".py",
    ".plist",
    ".pbxproj",
    ".xcconfig",
    ".json",
    ".strings",
    ".stringsdict",
    ".metal",
    ".entitlements",
    ".sh",
}

SPECIAL_FILES = {
    "Info.plist",
    "project.pbxproj",
    "Package.swift",
    "Podfile",
    "Podfile.lock",
}

EXCLUDED_DIRS = {
    ".git",
    ".build",
    "DerivedData",
    "build",
    "dist",
    "venv",
    ".venv",
    "__pycache__",
    ".pytest_cache",
    ".mypy_cache",
}

MAX_FILE_SIZE = 2 * 1024 * 1024


def is_code_file(path: Path) -> bool:
    return path.name in SPECIAL_FILES or path.suffix.lower() in CODE_EXTENSIONS


def collect_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for current_root, dirs, filenames in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d not in EXCLUDED_DIRS)
        for filename in sorted(filenames):
            path = Path(current_root) / filename
            if is_code_file(path):
                files.append(path)
    return sorted(files, key=lambda p: str(p.relative_to(root)))


def read_text(path: Path) -> str:
    try:
        size = path.stat().st_size
    except OSError:
        return ""

    if size > MAX_FILE_SIZE:
        return f"[SKIPPED: file is larger than {MAX_FILE_SIZE // (1024 * 1024)} MB]\n"

    for encoding in ("utf-8", "utf-8-sig"):
        try:
            return path.read_text(encoding=encoding)
        except UnicodeDecodeError:
            continue
        except OSError as exc:
            return f"[READ ERROR: {exc}]\n"

    return "[SKIPPED: not valid UTF-8 text]\n"


def build_payload(root: Path) -> str:
    files = collect_files(root)
    parts: list[str] = [IOS_PROMPT.rstrip(), "", "# PROJECT: Tape", f"# ROOT: {root}", f"# FILES: {len(files)}", ""]

    for path in files:
        relative = path.relative_to(root).as_posix()
        parts.extend(
            [
                "=" * 80,
                f"FILE: {relative}",
                "=" * 80,
                read_text(path).rstrip("\n"),
                "",
            ]
        )

    return "\n".join(parts).rstrip() + "\n"


def copy_to_clipboard(text: str) -> None:
    if sys.platform != "darwin":
        raise RuntimeError("wrapper.py currently requires macOS because it uses pbcopy")

    subprocess.run(
        ["pbcopy"],
        input=text,
        text=True,
        check=True,
    )


def main() -> int:
    root = Path(__file__).resolve().parent
    payload = build_payload(root)

    try:
        copy_to_clipboard(payload)
    except FileNotFoundError:
        print("Ошибка: команда pbcopy не найдена. Проверь, что wrapper.py запускается на macOS.", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as exc:
        print(f"Ошибка копирования в буфер обмена (pbcopy, exit {exc.returncode}).", file=sys.stderr)
        return 1
    except RuntimeError as exc:
        print(f"Ошибка: {exc}", file=sys.stderr)
        return 1

    file_count = payload.count("\nFILE: ")
    print(f"Скопировано в буфер обмена: {file_count} файлов.")
    print("В начале буфера добавлен prompt для senior iOS-разработчика.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
