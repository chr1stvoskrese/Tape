import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isPlaying = false
    @State private var progress = 0.38
    @State private var isPressed = false
    @State private var reelPhase: Double = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                TapePalette.shell
                    .ignoresSafeArea()

                CassettePlayerView(
                    isPlaying: isPlaying,
                    progress: progress,
                    reelPhase: reelPhase,
                    isPressed: isPressed,
                    onPrevious: {
                        haptic(.impact(.light))
                        withAnimation(.easeOut(duration: 0.25)) {
                            progress = max(0, progress - 0.07)
                        }
                    },
                    onPlayPause: {
                        let next = !isPlaying
                        haptic(next ? .impact(.medium) : .impact(.light))
                        withAnimation(.easeInOut(duration: next ? 0.7 : 0.4)) {
                            isPlaying = next
                        }
                        withAnimation(.linear(duration: 3.2).repeatForever(autoreverses: false)) {
                            reelPhase += next ? 360 : 0
                        }
                    },
                    onNext: {
                        haptic(.impact(.light))
                        withAnimation(.easeOut(duration: 0.25)) {
                            progress = min(1, progress + 0.07)
                        }
                    },
                    onSeek: { value in
                        progress = min(1, max(0, value))
                    },
                    onSeekEnded: {
                        haptic(.selection)
                    }
                )
                .frame(
                    width: min(proxy.size.height * 0.62, proxy.size.width * 0.31),
                    height: min(proxy.size.height * 0.86, proxy.size.width * 0.50)
                )
                .animation(.easeOut(duration: 0.25), value: proxy.size)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    private func haptic(_ event: HapticEvent) {
        switch event {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    private enum HapticEvent {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case selection
    }
}

private struct CassettePlayerView: View {
    let isPlaying: Bool
    let progress: Double
    let reelPhase: Double
    let isPressed: Bool
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onSeek: (Double) -> Void
    let onSeekEnded: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: w * 0.085, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                TapePalette.surface,
                                TapePalette.inset,
                                TapePalette.surface.opacity(0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: w * 0.085, style: .continuous)
                            .stroke(Color.white.opacity(0.085), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.48), radius: 30, y: 20)
                    .scaleEffect(isPressed ? 0.985 : 1)

                VStack(spacing: 0) {
                    cassetteBrand
                        .padding(.top, h * 0.055)

                    Spacer(minLength: 8)

                    reelWindow
                        .frame(height: h * 0.42)

                    Spacer(minLength: 10)

                    trackInfo

                    seekControl
                        .padding(.top, h * 0.03)

                    transport
                        .padding(.top, h * 0.035)
                        .padding(.bottom, h * 0.055)
                }
                .padding(.horizontal, w * 0.095)
            }
            .contentShape(Rectangle())
        }
        .accessibilityElement(children: .contain)
    }

    private var cassetteBrand: some View {
        HStack(alignment: .center) {
            Text("TAPE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(4.2)
                .foregroundStyle(TapePalette.text.opacity(0.78))

            Spacer()

            Circle()
                .fill(isPlaying ? TapePalette.accent : Color.white.opacity(0.12))
                .frame(width: 5, height: 5)
                .shadow(color: isPlaying ? TapePalette.accent.opacity(0.7) : .clear, radius: 7)
        }
    }

    private var reelWindow: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height * 1.55)
            let reel = min(proxy.size.height * 0.75, size * 0.36)

            ZStack {
                RoundedRectangle(cornerRadius: proxy.size.height * 0.08, style: .continuous)
                    .fill(Color.black.opacity(0.18))
                    .overlay {
                        RoundedRectangle(cornerRadius: proxy.size.height * 0.08, style: .continuous)
                            .stroke(Color.white.opacity(0.065), lineWidth: 1)
                    }

                HStack(spacing: proxy.size.width * 0.06) {
                    CassetteReel(size: reel, rotation: reelPhase * 0.94, isPlaying: isPlaying)
                    TapePath()
                    CassetteReel(size: reel, rotation: -reelPhase * 1.12, isPlaying: isPlaying)
                }
                .padding(.horizontal, proxy.size.width * 0.09)
            }
        }
    }

    private var trackInfo: some View {
        VStack(spacing: 5) {
            Text("Night Drive")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .tracking(-0.35)
                .foregroundStyle(TapePalette.text)
                .lineLimit(1)

            Text("CHROMATICS  ·  SIDE A")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(TapePalette.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var seekControl: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.075))
                    .frame(height: 2)

                Capsule()
                    .fill(TapePalette.accent.opacity(0.9))
                    .frame(width: max(3, width * progress), height: 2)

                Circle()
                    .fill(TapePalette.text.opacity(0.95))
                    .frame(width: 6, height: 6)
                    .offset(x: max(0, width * progress - 3))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onSeek(value.location.x / width)
                    }
                    .onEnded { _ in
                        onSeekEnded()
                    }
            )
        }
        .frame(height: 14)
        .overlay {
            HStack {
                Text(timeString(progress))
                Spacer()
                Text("04:12")
            }
            .font(.system(size: 7.5, weight: .medium, design: .monospaced))
            .tracking(0.8)
            .foregroundStyle(TapePalette.muted.opacity(0.9))
            .offset(y: 13)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playback position")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onSeek(progress + 0.05)
            case .decrement: onSeek(progress - 0.05)
            @unknown default: break
            }
        }
    }

    private var transport: some View {
        HStack(spacing: 0) {
            CassetteButton(systemName: "backward.fill", size: 13, action: onPrevious)

            Spacer()

            CassetteButton(
                systemName: isPlaying ? "pause.fill" : "play.fill",
                size: 16,
                primary: true,
                action: onPlayPause
            )

            Spacer()

            CassetteButton(systemName: "forward.fill", size: 13, action: onNext)
        }
    }

    private func timeString(_ value: Double) -> String {
        let totalSeconds = Int(value * 252)
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

private struct CassetteReel: View {
    let size: CGFloat
    let rotation: Double
    let isPlaying: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.11),
                            Color.white.opacity(0.035),
                            Color.black.opacity(0.33)
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: size * 0.72
                    )
                )
                .overlay(Circle().stroke(Color.white.opacity(0.11), lineWidth: 1))

            Circle()
                .stroke(Color.black.opacity(0.36), lineWidth: size * 0.08)
                .padding(size * 0.13)

            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Capsule(style: .circular)
                        .fill(Color.white.opacity(0.13))
                        .frame(width: size * 0.045, height: size * 0.28)
                        .offset(y: -size * 0.18)
                        .rotationEffect(.degrees(Double(index) * 72))
                }
            }
            .rotationEffect(.degrees(rotation))
            .animation(
                isPlaying
                    ? .linear(duration: 2.6).repeatForever(autoreverses: false)
                    : .easeOut(duration: 0.45),
                value: isPlaying
            )

            Circle()
                .fill(TapePalette.inset)
                .frame(width: size * 0.27)
                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))

            Circle()
                .fill(TapePalette.accent.opacity(0.9))
                .frame(width: size * 0.055)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.4), radius: size * 0.10, y: size * 0.06)
    }
}

private struct TapePath: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.065))
                    .frame(width: proxy.size.width, height: 2)

                Capsule()
                    .fill(TapePalette.accent.opacity(0.18))
                    .frame(width: proxy.size.width * 0.7, height: 1)

                VStack(spacing: 3) {
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 4, height: 4)
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CassetteButton: View {
    let systemName: String
    let size: CGFloat
    var primary = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            pressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                withAnimation(.easeOut(duration: 0.14)) {
                    pressed = false
                }
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(primary ? TapePalette.shell : TapePalette.text.opacity(0.86))
                .frame(width: primary ? 42 : 34, height: primary ? 42 : 34)
                .background {
                    Circle()
                        .fill(primary ? TapePalette.accent : Color.white.opacity(0.06))
                        .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .scaleEffect(pressed ? 0.91 : 1)
                .offset(y: pressed ? 1.5 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            systemName == "play.fill" ? "Play" :
            systemName == "pause.fill" ? "Pause" :
            systemName.contains("backward") ? "Previous track" : "Next track"
        )
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
