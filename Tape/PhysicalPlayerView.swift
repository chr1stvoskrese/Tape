import SwiftUI
import UIKit

struct PhysicalPlayerView: View {
    @State private var isPlaying = false
    @State private var reelRotation: Double = 0
    @State private var pressedControl: Control?
    @State private var volume: Double = 0.72
    @State private var selectedPreset = 0

    private let bodyColor = Color(red: 0.095, green: 0.095, blue: 0.09)
    private let metalColor = Color(red: 0.25, green: 0.25, blue: 0.235)
    private let amber = Color(red: 1.0, green: 0.47, blue: 0.08)

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                deck(in: proxy.size)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    private func deck(in screen: CGSize) -> some View {
        let height = min(screen.height * 0.86, 620)
        let width = min(screen.width * 0.88, 860)

        return ZStack {
            roundedPanel(cornerRadius: 34)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.17, green: 0.17, blue: 0.16),
                            bodyColor,
                            Color(red: 0.055, green: 0.055, blue: 0.052)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    roundedPanel(cornerRadius: 34)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.75), radius: 38, y: 24)

            VStack(spacing: 0) {
                topPlate
                    .frame(height: height * 0.18)

                displayWindow
                    .frame(height: height * 0.56)
                    .padding(.horizontal, width * 0.075)

                bottomControls
                    .frame(height: height * 0.26)
            }
            .frame(width: width, height: height)
            .padding(.horizontal, width * 0.025)
        }
        .frame(width: width, height: height)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape physical music player")
    }

    private var topPlate: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                metalButton(.previous, systemName: "backward.fill")
                metalButton(.next, systemName: "forward.fill")
            }

            Spacer()

            VStack(spacing: 3) {
                Text("TAPE")
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .tracking(5)
                Text("REEL / 01")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(2.3)
                    .foregroundStyle(.white.opacity(0.42))
            }

            Spacer()

            HStack(spacing: 8) {
                metalButton(.volumeDown, systemName: "speaker.wave.1.fill")
                metalButton(.volumeUp, systemName: "speaker.wave.3.fill")
            }
        }
        .padding(.horizontal, 20)
    }

    private var displayWindow: some View {
        GeometryReader { proxy in
            let reelDiameter = min(proxy.size.height * 0.72, proxy.size.width * 0.38)

            ZStack {
                roundedPanel(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: [Color.black, Color(red: 0.015, green: 0.017, blue: 0.015)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        roundedPanel(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }

                HStack(spacing: proxy.size.width * 0.08) {
                    reel(size: reelDiameter, tint: Color(red: 0.13, green: 0.13, blue: 0.125), dark: true)
                    reel(size: reelDiameter, tint: amber, dark: false)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    HStack {
                        statusLight
                        Spacer()
                        Text(isPlaying ? "PLAYING" : "PAUSED")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1.5)
                            .foregroundStyle(isPlaying ? amber : .white.opacity(0.34))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)

                    Spacer()

                    HStack(spacing: 7) {
                        ForEach(0..<14, id: \.self) { index in
                            let level = isPlaying
                                ? abs(sin(Double(index) * 0.82 + reelRotation * 0.015))
                                : 0.22 + Double(index % 3) * 0.04

                            RoundedRectangle(cornerRadius: 2)
                                .fill(amber.opacity(0.28 + level * 0.72))
                                .frame(height: CGFloat(7 + level * 15))
                        }
                    }
                    .frame(height: 24)
                    .padding(.horizontal, 26)
                    .padding(.bottom, 14)
                }
            }
        }
    }

    private var statusLight: some View {
        Circle()
            .fill(isPlaying ? amber : Color.white.opacity(0.12))
            .frame(width: 8, height: 8)
            .shadow(color: isPlaying ? amber.opacity(0.8) : .clear, radius: 7)
    }

    private func reel(size: CGFloat, tint: Color, dark: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            tint.opacity(dark ? 0.92 : 0.95),
                            tint.opacity(dark ? 0.55 : 0.82),
                            .black.opacity(0.98)
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: size * 0.52
                    )
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.13), lineWidth: 2)
                        .padding(2)
                }

            Circle()
                .stroke(Color.white.opacity(dark ? 0.13 : 0.20), lineWidth: size * 0.018)
                .padding(size * 0.085)

            Circle()
                .fill(Color(red: 0.025, green: 0.025, blue: 0.023))
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.13), lineWidth: 2)
                }

            ForEach(0..<6, id: \.self) { index in
                Capsule(style: .circular)
                    .fill(Color.white.opacity(dark ? 0.10 : 0.14))
                    .frame(width: max(4, size * 0.035), height: size * 0.22)
                    .offset(y: -size * 0.18)
                    .rotationEffect(.degrees(Double(index) * 60))
            }

            Circle()
                .fill(Color(red: 0.82, green: 0.66, blue: 0.36))
                .frame(width: size * 0.075, height: size * 0.075)
                .shadow(color: .black.opacity(0.7), radius: 3)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(reelRotation))
        .animation(
            isPlaying
                ? .linear(duration: 2.0).repeatForever(autoreverses: false)
                : .easeOut(duration: 0.22),
            value: reelRotation
        )
        .onChange(of: isPlaying) { _, playing in
            if playing {
                reelRotation += 360
            }
        }
    }

    private var bottomControls: some View {
        HStack(spacing: 14) {
            roundControl(.eq, label: "EQ", icon: "slider.horizontal.3")

            VStack(alignment: .leading, spacing: 7) {
                Text("OUTPUT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.36))

                HStack(spacing: 5) {
                    ForEach(0..<8, id: \.self) { index in
                        let active = Double(index) < volume * 8
                        Capsule(style: .circular)
                            .fill(active ? amber : Color.white.opacity(0.10))
                            .frame(width: 4, height: 18 + CGFloat(index % 3) * 5)
                    }
                }
            }

            Spacer(minLength: 4)

            Button {
                togglePlayback()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [metalColor.opacity(1), Color(red: 0.11, green: 0.11, blue: 0.105)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Circle().stroke(Color.white.opacity(0.13), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.55), radius: 10, y: 7)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(x: isPlaying ? 0 : 2)
                }
                .frame(width: 70, height: 70)
                .scaleEffect(pressedControl == .playPause ? 0.93 : 1)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 4)

            roundControl(.preset, label: "PRE", icon: "waveform.path.ecg")
            roundControl(.volumeUp, label: "VOL", icon: "speaker.wave.3.fill")
        }
        .padding(.horizontal, 18)
    }

    private func roundedPanel(cornerRadius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private func metalButton(_ control: Control, systemName: String) -> some View {
        Button {
            trigger(control)
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 36, height: 32)
                .background(
                    LinearGradient(
                        colors: [metalColor, Color(red: 0.11, green: 0.11, blue: 0.105)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.white.opacity(0.11), lineWidth: 1)
                }
                .foregroundStyle(.white.opacity(0.84))
        }
        .buttonStyle(.plain)
        .scaleEffect(pressedControl == control ? 0.92 : 1)
    }

    private func roundControl(_ control: Control, label: String, icon: String) -> some View {
        Button {
            trigger(control)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(label)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .tracking(0.8)
            }
            .frame(width: 54, height: 54)
            .background(
                LinearGradient(
                    colors: [metalColor, Color(red: 0.10, green: 0.10, blue: 0.095)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            }
            .foregroundStyle(.white.opacity(0.82))
        }
        .buttonStyle(.plain)
        .scaleEffect(pressedControl == control ? 0.94 : 1)
    }

    private func togglePlayback() {
        trigger(.playPause)
    }

    private func trigger(_ control: Control) {
        pressedControl = control

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            withAnimation(.easeOut(duration: 0.12)) {
                pressedControl = nil
            }
        }

        switch control {
        case .playPause:
            isPlaying.toggle()
            haptic(isPlaying ? .medium : .light)
        case .previous:
            haptic(.rigid)
        case .next:
            haptic(.rigid)
        case .volumeDown:
            volume = max(0, volume - 0.08)
            haptic(.selection)
        case .volumeUp:
            volume = min(1, volume + 0.08)
            haptic(.selection)
        case .eq:
            selectedPreset = (selectedPreset + 1) % 4
            haptic(.selection)
        case .preset:
            selectedPreset = (selectedPreset + 1) % 4
            haptic(.selection)
        }
    }

    private enum HapticKind {
        case light, medium, rigid, selection
    }

    private func haptic(_ kind: HapticKind) {
        switch kind {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare()
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    private enum Control: Hashable {
        case previous
        case next
        case volumeDown
        case volumeUp
        case eq
        case preset
        case playPause
    }
}
