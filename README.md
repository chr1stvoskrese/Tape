# Tape

> **A tiny music player that refuses to look like an app.**

Tape is a premium indie iPhone music player for people who keep their own music.

The goal is deliberately simple: take the phone, turn it sideways, and make the entire interface feel like a beautifully designed piece of hi-fi hardware.

No feed. No cloud. No account. No subscription. No algorithm telling you what to listen to.

Just your music, inside a small physical-looking machine.

<p align="center">
  <strong>LOCAL MUSIC · LOSSLESS · TACTILE · MINIMAL</strong>
</p>

---

## The idea

Most music apps are built like software products: tabs, cards, lists, recommendations, navigation chrome and endless surfaces competing for attention.

Tape takes the opposite approach.

The **player is the interface**.

On a landscape iPhone, one compact vertical hi-fi/cassette object sits in the center of a large field of negative space. The phone becomes the machine. Controls belong to the object, not to an app toolbar.

The design language is inspired by the physical qualities of compact audio hardware:

- recessed surfaces
- smoked glass
- warm graphite materials
- machined-looking rings and buttons
- tiny technical markings
- mechanical movement
- restrained typography
- tactile interaction
- almost obsessive negative space

The reference is analogue hardware, but the execution is modern and original. Tape should feel nostalgic without becoming a retro toy.

---

## Product philosophy

### One screen

There is one main screen because a small music player does not need a maze of screens.

### The object comes first

Track information, transport controls and playback state should belong to the physical illusion of the player.

### Motion has weight

Reels do not simply switch between `on` and `off`. They accelerate, coast and stop. Buttons depress. Interactions have a little physical consequence.

### Haptics are part of the design

A tap should feel intentional. Different actions should have different tactile signatures, and the app should never vibrate just because it can.

### Less software, more object

Every visible element has to justify its existence. If removing it makes the player calmer and more beautiful, remove it.

---

## Current prototype

The current build is **Stage 1: the physical player**.

It already establishes the visual and interaction language:

- landscape-only iPhone presentation
- centered vertical player object
- mechanical dual reels
- recessed playback surface
- minimal transport controls
- integrated seek interaction
- tactile button press states
- playback and seek haptics
- mechanical reel animation
- technical micro-labels
- dark warm material palette
- accessibility labels for primary interactions

The prototype intentionally does **not** pretend to be a finished audio engine yet. We are locking the industrial design before adding engineering complexity.

---

## What Tape is becoming

The finished product is intended to be a small paid music player for local files.

### Audio

Target formats include common and lossless formats such as:

- FLAC
- ALAC / Apple Lossless
- WAV
- AIFF
- MP3
- AAC

The principle is straightforward: **do not unnecessarily transcode the user's music**. Where the system audio stack is insufficient, we will evaluate a dedicated decoder/backend on a format-by-format basis instead of adding a large dependency by default.

### Library

Users will be able to choose music through the native Files picker, including:

- iCloud Drive
- On My iPhone
- other locations exposed through Files

Selected files should persist between launches and degrade gracefully when files are moved or disappear.

### Playback

Planned playback capabilities:

- play / pause
- previous / next
- seek
- volume
- queue
- metadata and artwork
- duration
- bitrate / sample rate where available
- background audio
- Lock Screen / Control Center controls
- AirPods and headphone transport controls

### Explicitly not the product

Tape is **not** trying to become a mini Spotify.

There are no plans for:

- subscriptions
- ads
- accounts
- social features
- recommendations
- streaming catalogues
- lyrics-first UX
- giant library management screens
- unnecessary settings
- an enterprise-sized architecture

The product should stay small enough to polish obsessively.

---

## Technology

Tape is intentionally built with a small modern Apple stack.

- **Swift**
- **SwiftUI** for the interface
- **AVFoundation** for the system audio path where appropriate
- **UIKit haptics** where they provide better tactile control
- native iOS Files / document APIs for local music import
- native Now Playing / Remote Command APIs for system playback integration

We are avoiding a dependency pile. Third-party audio decoders will only be introduced when there is a concrete format or fidelity requirement that Apple frameworks cannot meet well enough.

---

## Project structure

```text
Tape/
├── Tape.xcodeproj/
└── Tape/
    ├── TapeApp.swift
    ├── ContentView.swift
    ├── ReelAssemblyView.swift
    ├── DesignSystem.swift
    └── Info.plist

run.py
README.md
```

### Responsibilities

`ContentView.swift`

The main composition of the player: layout, playback affordances, seek interaction and tactile responses.

`ReelAssemblyView.swift`

The mechanical layer: reels, hubs, tape bridge details and motion.

`DesignSystem.swift`

The visual language: palette, typography and reusable design primitives.

`Info.plist`

The current presentation contract, including landscape-only iPhone orientation.

`run.py`

A zero-friction developer launcher for macOS: open Xcode, choose an available basic iPhone Simulator, boot it, build Tape, install it and launch it.

---

## Run it

### Requirements

A Mac with:

- Xcode
- iOS Simulator
- Python 3

No third-party Python packages are required.

### One command

From the repository root:

```bash
python3 run.py
```

The launcher is designed to remove the boring setup steps. It opens the Xcode project, picks a simple available iPhone Simulator (preferring iPhone SE when available), boots Simulator, builds the app and launches it.

Manual Xcode launch remains possible too:

```bash
open Tape.xcodeproj
```

---

## Development workflow

The project is being built in deliberately small slices.

### 01 — Physical design

Make the player feel expensive before adding complexity.

### 02 — Real audio

Connect the playback engine and verify local files, lossless formats and timing behaviour.

### 03 — Files + library

Add file picking, metadata extraction, artwork and persistent library state.

### 04 — System playback

Add background audio, Lock Screen, Control Center, headphones and AirPods controls.

### 05 — Polish

Tune animation curves, haptics, typography, materials, accessibility and edge cases until the device feels coherent.

### 06 — App Store

Prepare the paid product, metadata, screenshots, iconography, privacy details, review requirements and release build.

---

## Design rules

These are intentionally opinionated.

**Do not make it look like Apple Music.**

**Do not add a UI element because SwiftUI makes it easy.**

**Do not solve a physical interaction with a generic list if the player can solve it.**

**Do not use animation without a reason.**

**Do not add haptics to every tap.**

**Do not hide poor hierarchy behind more decoration.**

**Do not sacrifice readability for nostalgia.**

**Do not turn a five-control device into a forty-control application.**

The standard is simple:

> **If it looks like an app, we probably haven't finished designing it.**

---

## Status

**Prototype — design / interaction stage**

The repository is an active product build, not a tutorial project.

The current priority is to make the central player object genuinely memorable before expanding functionality.

---

## License

License and App Store distribution terms will be decided before the first public release.
