# Tape

Tape is a tiny landscape iPhone music player designed to feel like a physical hi-fi object rather than a conventional app UI.

## Current direction

- One centered vertical player on a landscape iPhone canvas.
- Minimal transport: previous, play/pause, next.
- Seek is integrated into the player rather than presented as a standard SwiftUI control.
- Warm graphite materials, recessed window, mechanical reels, small monochrome labeling.
- Tactile feedback for transport controls and scrubbing.
- No tab bar, dashboard, cards, or secondary navigation.

The visual reference is the language of compact cassette / hi-fi hardware: physical proportions, recessed glass, tiny markings, mechanical details, and restrained information density. The implementation is intentionally original rather than a copy of a specific device.

## Run on macOS

With Xcode and the iOS Simulator installed, from the repository root:

```bash
python3 run.py
```

The launcher opens `Tape.xcodeproj`, chooses the simplest available iPhone Simulator (preferring iPhone SE when installed), boots Simulator, builds the app, installs it, and launches it.

No third-party Python packages are required.

## Architecture for this stage

This first pass is deliberately small:

- `Tape/ContentView.swift` — composition of the physical player surface and interactions.
- `Tape/ReelAssemblyView.swift` — mechanical reel rendering and playback motion.
- `Tape/DesignSystem.swift` — materials, typography, palette, and haptics.
- `Tape/Info.plist` — landscape-only iPhone presentation.
- `run.py` — one-command local Xcode/Simulator launcher.

The real audio engine, Files picker, library persistence, background audio, and Lock Screen integration are intentionally deferred until the physical UI feels right.
