# Tape

<p align="center">
  <strong>THE PLAYER IS THE INTERFACE.</strong>
</p>

<p align="center">
  A tiny, paid, lossless-first music player for iPhone — designed like a piece of hi-fi hardware instead of an app.
</p>

<p align="center">
  <code>LOCAL MUSIC</code>&nbsp;&nbsp;·&nbsp;&nbsp;<code>LOSSLESS</code>&nbsp;&nbsp;·&nbsp;&nbsp;<code>TACTILE</code>&nbsp;&nbsp;·&nbsp;&nbsp;<code>MINIMAL</code>
</p>

---

## Why Tape exists

Most music players are software first: tabs, cards, lists, recommendations, feeds, settings and navigation everywhere.

Tape goes the other way.

Turn the iPhone sideways and the screen becomes a **small physical music machine**. One vertical hi-fi / cassette-inspired object sits in the middle of a huge field of negative space. The controls belong to the machine, not to an app chrome layer.

No feed.

No account.

No ads.

No subscription.

No streaming catalogue.

No algorithm telling you what to hear.

**Just your music, inside a beautifully designed object.**

---

## The design brief

Tape is deliberately opinionated.

The visual target is not “retro app”. It is **modern industrial hardware with an analogue soul**.

Think:

- warm graphite and smoked surfaces
- recessed mechanical details
- machined rings and small physical controls
- restrained typography
- tiny technical markings
- believable movement
- short, deliberate transitions
- tactile feedback
- enormous negative space
- almost nothing that does not need to be there

The inspiration comes from compact hi-fi and cassette hardware, but the execution is original. The goal is nostalgia without cosplay.

> **If it looks like a normal app, we probably haven't finished.**

---

## Product principles

### 01 — The object comes first

The player is the main character. Track information, transport controls, progress and playback state should feel embedded in the physical device.

### 02 — One screen is enough

A small music player does not need a navigation maze. The default experience should be understandable immediately.

### 03 — Motion has weight

Reels accelerate, coast and stop. Buttons physically depress. State changes should feel mechanical rather than like boolean flags changing on screen.

### 04 — Haptics are part of the UI

Different actions should have different tactile signatures. Important interactions get feedback; meaningless taps do not create a vibration circus.

### 05 — Negative space is a feature

The empty space around the player is intentional. It gives the object scale, calm and presence.

### 06 — Small product, obsessive polish

Tape is intentionally tiny in scope. The point is not to win a feature checklist. The point is to make five things feel unbelievably good.

---

## Current state

**Stage 1 — physical player / interaction prototype**

The repository currently establishes the industrial design language before the real audio engine is introduced.

Already in place:

- landscape-only iPhone presentation
- centered vertical player object
- dual mechanical reels
- recessed playback surface
- minimal transport controls
- integrated seek interaction
- physical-looking button press states
- contextual haptics
- mechanical reel animation
- technical micro-labels
- warm dark material palette
- primary accessibility labels
- zero-dependency macOS launcher script

The prototype is intentionally small. We are not pretending that the audio backend is finished yet.

---

## What the finished product should do

Tape is intended to become a **$2.99 one-time purchase** with no subscription model.

### Local music

Users choose their own files through the native Files picker:

- iCloud Drive
- On My iPhone
- other Files locations exposed by iOS

The library should persist between launches and handle moved or missing files without falling apart.

### Audio formats

Target support includes common and lossless formats:

| Format | Goal |
| --- | --- |
| FLAC | First-class lossless support |
| ALAC / Apple Lossless | First-class lossless support |
| WAV | First-class lossless support |
| AIFF | First-class lossless support |
| MP3 | Standard support |
| AAC | Standard support |

The rule is simple: **do not unnecessarily transcode the user's music**.

We will prefer Apple's native audio path where it is sufficient. A dedicated decoder/backend should only be introduced when a concrete format or fidelity requirement justifies the additional complexity.

### Playback

The MVP is intentionally narrow:

- play / pause
- previous / next
- seek
- volume
- queue
- title / artist / album metadata
- artwork
- duration
- bitrate / sample rate where available
- background audio
- Lock Screen controls
- Control Center controls
- AirPods / headphone transport controls

### Things we are deliberately not building

Tape is **not** trying to become Spotify.

No plans for:

- subscriptions
- ads
- accounts
- social features
- recommendations
- streaming catalogues
- lyrics-first UX
- giant library management screens
- analytics dashboards
- complicated settings
- unnecessary themes
- enterprise architecture

Every feature has to answer one question:

> **Does this make the little player better?**

If not, it does not belong.

---

## Technology

Tape uses a deliberately small Apple-native stack.

| Layer | Technology |
| --- | --- |
| UI | SwiftUI |
| Language | Swift |
| Audio | AVFoundation where appropriate |
| Haptics | UIKit feedback generators / modern iOS haptics |
| Files | Native iOS document / Files APIs |
| System playback | Now Playing + Remote Command APIs |
| Architecture | Small, explicit components — no framework zoo |

The project should stay easy to understand six months from now.

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

### File roles

**`ContentView.swift`**

Main composition of the player, interaction state, seek behaviour and tactile responses.

**`ReelAssemblyView.swift`**

Mechanical visual layer: reels, hubs, bridge details and motion.

**`DesignSystem.swift`**

Visual language: palette, typography and reusable primitives.

**`Info.plist`**

Application presentation contract, including the current landscape-only orientation.

**`run.py`**

One-command macOS launcher that opens Xcode, chooses an available basic iPhone Simulator, boots it, builds Tape, installs it and launches it.

---

## Run it without thinking

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

The launcher is deliberately boring. It should remove the boring parts of development:

1. open the Xcode project
2. find a basic available iPhone Simulator
3. boot Simulator
4. build Tape
5. install Tape
6. launch Tape

You can still open the project manually when needed:

```bash
open Tape.xcodeproj
```

---

## Development roadmap

The order matters. We are not building everything at once.

### 01 — Physical design

Make the device feel expensive.

Materials, proportions, typography, reels, controls, motion, haptics and negative space.

### 02 — Real audio

Connect the playback engine and verify timing, interruptions, seeking and lossless playback.

### 03 — Files + library

Add file picking, metadata, artwork and persistence.

### 04 — System playback

Add background audio, Lock Screen, Control Center, headphones and AirPods.

### 05 — Polish

Tune every curve, haptic, spacing decision, accessibility label and edge case.

### 06 — App Store

Create the production build, screenshots, icon, metadata, privacy details, paid pricing and App Store submission package.

---

## Design rules

These are product rules, not suggestions.

**Do not make it look like Apple Music.**

**Do not add UI because SwiftUI makes it easy.**

**Do not solve a physical interaction with a generic list when the device can solve it.**

**Do not animate without purpose.**

**Do not add haptics to every tap.**

**Do not use nostalgia as an excuse for bad readability.**

**Do not add a second screen until the first screen has earned it.**

**Do not turn a five-control device into a forty-control application.**

---

## Definition of done

Tape is ready for the App Store when it passes the following test:

> **You rotate the iPhone, see the object, touch it, and immediately understand that this is a music player — without seeing a conventional app UI.**

And then the important second test:

> **It feels better to use than a $2.99 app has any right to feel.**

---

## Status

**Prototype · active development**

This repository is a real product build, not a tutorial project.

The current priority is the physical player itself. Audio engineering comes after the interaction and industrial design are strong enough to deserve it.

---

## License

License and App Store distribution terms will be finalized before the public release.

---

<p align="center">
  <strong>TAPE</strong><br>
  <sub>Your music. One machine.</sub>
</p>
