import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isPlaying = false
    @State private var progress = 0.38
    @State private var pressedControl: Control? = nil

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                TapeBackdrop()

                VerticalPlayer(
                    isPlaying: isPlaying,
                    progress: $progress,
                    pressedControl: $pressedControl,
                    onPlayPause: togglePlayback,
                    onPrevious: previousTrack,
                    onNext: nextTrack
                )
                .frame(
                    width: min(proxy.size.height * 0.66, 252),
                    height: min(proxy.size.height * 0.90, 380)
                )
                .animation(.snappy(duration: 0.24), value: isPlaying)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    private func togglePlayback() {
        let next = !isPlaying
        withAnimation(.easeInOut(duration: next ? 0.55 : 0.32)) {
            isPlaying = next
        }
        Haptics.transport(next ? .play : .pause)
    }

    private func previousTrack() {
        withAnimation(.snappy(duration: 0.22)) {
            progress = 0
        }
        Haptics.transport(.skip)
    }

    private func nextTrack() {
        withAnimation(.snappy(duration: 0.22)) {
            progress = 0
        }
        Haptics.transport(.skip)
    }

    enum Control {
        case previous, playPause, next
    }
}

private struct TapeBackdrop: View {
    var body: some View {
        ZStack {
            Color(red: 0.022, green: 0.021, blue: 0.019)

            RadialGradient(
                colors: [
                    Color.white.opacity(0.045),
                    .clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 430
            )

            LinearGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.30),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct VerticalPlayer: View {
    let isPlaying: Bool
    @Binding var progress: Double
    @Binding var pressedControl: ContentView.Control?

    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        ZStack {
            deviceShadow
            deviceBody
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape music player")
    }

    private var deviceShadow: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.black.opacity(0.60))
            .blur(radius: 16)
            .offset(y: 16)
            .scaleEffect(0.94)
    }

    private var deviceBody: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: width * 0.105, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                TapePalette.deviceTop,
                                TapePalette.device,
                                TapePalette.deviceBottom
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: width * 0.105, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    }

                VStack(spacing: 0) {
                    topCap
                        .frame(height: height * 0.10)

                    cassetteWindow
                        .frame(height: height * 0.47)
                        .padding(.horizontal, width * 0.095)

                    metadata
                        .frame(height: height * 0.14)
                        .padding(.horizontal, width * 0.105)

                    progressStrip
                        .padding(.horizontal, width * 0.105)

                    Spacer(minLength: 0)

                    transportDeck
                        .frame(height: height * 0.20)
                        .padding(.horizontal, width * 0.075)
                        .padding(.bottom, height * 0.035)
                }
                .padding(.horizontal, width * 0.035)
            }
        }
    }

    private var topCap: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center) {
                MonospacedLabel(text: "TAPE", size: 8, tracking: 2.4, color: TapePalette.softText)

                Spacer()

                HStack(spacing: 5) {
                    Circle()
                        .fill(isPlaying ? TapePalette.accent : TapePalette.mutedDot)
                        .frame(width: 4, height: 4)
                        .shadow(color: isPlaying ? TapePalette.accent.opacity(0.55) : .clear, radius: 4)

                    MonospacedLabel(
                        text: isPlaying ? "PLAY" : "READY",
                        size: 7,
                        tracking: 1.4,
                        color: isPlaying ? TapePalette.accent : TapePalette.muted
                    )
                }
            }

            Capsule()
                .fill(Color.black.opacity(0.35))
                .frame(height: 1)
        }
        .padding(.horizontal, 7)
        .padding(.top, 6)
    }

    private var cassetteWindow: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                RoundedRectangle(cornerRadius: size * 0.105, style: .continuous)
                    .fill(TapePalette.window)
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.105, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.45), radius: 10, y: 6)

                VStack(spacing: 0) {
                    HStack(spacing: size * 0.08) {
                        ReelView(isPlaying: isPlaying, side: .left)
                        TapeGuide(width: size * 0.11)
                        ReelView(isPlaying: isPlaying, side: .right)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, size * 0.10)

                    Spacer(minLength: size * 0.04)

                    HStack {
                        Text("HI-FI / LOSSLESS")
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .tracking(1.4)
                            .foregroundStyle(TapePalette.windowText.opacity(0.52))
                        Spacer()
                        Text("01")
                            .font(.system(size: 7, weight: .semibold, design: .monospaced))
                            .foregroundStyle(TapePalette.accent.opacity(0.82))
                    }
                    .padding(.horizontal, size * 0.12)
                }
                .padding(.vertical, size * 0.12)
            }
        }
    }

    private var metadata: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Night Drive")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(-0.15)
                    .foregroundStyle(TapePalette.text)
                    .lineLimit(1)

                Text("Chromatics")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(TapePalette.muted)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 3) {
                Text("FLAC")
                    .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                    .tracking(1.0)
                    .foregroundStyle(TapePalette.accent)
                Text("24 / 96")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundStyle(TapePalette.muted)
            }
        }
    }

    private var progressStrip: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let thumbX = max(0, min(width * progress, width))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.09))
                    .frame(height: 2)

                Capsule()
                    .fill(TapePalette.accent)
                    .frame(width: max(2, thumbX), height: 2)

                Circle()
                    .fill(TapePalette.windowText)
                    .frame(width: 6, height: 6)
                    .offset(x: thumbX - 3)
            }
            .frame(height: 16)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let next = min(1, max(0, value.location.x / width))
                        if abs(next - progress) > 0.035 {
                            Haptics.scrubTick()
                        }
                        progress = next
                    }
                    .onEnded { _ in
                        Haptics.scrubEnd()
                    }
            )
        }
        .frame(height: 18)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playback position")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                progress = min(1, progress + 0.05)
                Haptics.scrubTick()
            case .decrement:
                progress = max(0, progress - 0.05)
                Haptics.scrubTick()
            @unknown default:
                break
            }
        }
    }

    private var transportDeck: some View {
        HStack(spacing: 12) {
            PlayerButton(
                title: "Previous",
                systemName: "backward.fill",
                control: .previous,
                pressedControl: $pressedControl,
                action: onPrevious
            )

            PlayerButton(
                title: isPlaying ? "Pause" : "Play",
                systemName: isPlaying ? "pause.fill" : "play.fill",
                control: .playPause,
                isPrimary: true,
                pressedControl: $pressedControl,
                action: onPlayPause
            )

            PlayerButton(
                title: "Next",
                systemName: "forward.fill",
                control: .next,
                pressedControl: $pressedControl,
                action: onNext
            )
        }
    }
}

private struct PlayerButton: View {
    let title: String
    let systemName: String
    let control: ContentView.Control
    var isPrimary = false
    @Binding var pressedControl: ContentView.Control?
    let action: () -> Void

    private var isPressed: Bool { pressedControl == control }

    var body: some View {
        Button {
            pressedControl = control
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                withAnimation(.easeOut(duration: 0.12)) {
                    pressedControl = nil
                }
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: isPrimary ? 13 : 10, weight: .bold))
                .foregroundStyle(isPrimary ? TapePalette.buttonInk : TapePalette.text)
                .frame(width: isPrimary ? 48 : 38, height: isPrimary ? 42 : 36)
                .background {
                    RoundedRectangle(cornerRadius: isPrimary ? 12 : 10, style: .continuous)
                        .fill(isPrimary ? TapePalette.accent : TapePalette.button)
                        .overlay {
                            RoundedRectangle(cornerRadius: isPrimary ? 12 : 10, style: .continuous)
                                .stroke(Color.white.opacity(isPrimary ? 0.12 : 0.07), lineWidth: 1)
                        }
                }
                .scaleEffect(isPressed ? 0.94 : 1)
                .offset(y: isPressed ? 1.5 : 0)
                .shadow(color: .black.opacity(0.38), radius: isPressed ? 1 : 4, y: isPressed ? 1 : 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
