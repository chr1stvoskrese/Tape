import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isPlaying = false
    @State private var progress = 0.38
    @State private var spin: Double = 0

    var body: some View {
        ZStack {
            TapePalette.shell.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                playerSurface
                controlRow
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                MonospacedLabel(text: "TAPE / 001", size: 11, tracking: 2.0, color: TapePalette.text)
                MonospacedLabel(text: "LOCAL", size: 9, tracking: 2.2)
            }

            Spacer()

            Circle()
                .fill(TapePalette.accent)
                .frame(width: 6, height: 6)
                .shadow(color: TapePalette.accent.opacity(0.55), radius: 6)
                .accessibilityLabel("Ready")
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
    }

    private var playerSurface: some View {
        VStack(spacing: 0) {
            ReelAssemblyView(isPlaying: isPlaying, spin: spin)
                .frame(maxWidth: .infinity)
                .frame(height: 310)
                .padding(.top, 14)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Night Drive")
                            .font(.system(size: 29, weight: .semibold, design: .rounded))
                            .tracking(-0.8)
                            .foregroundStyle(TapePalette.text)
                        Text("Chromatics")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(TapePalette.muted)
                    }

                    Spacer()

                    MonospacedLabel(text: "FLAC 24/96", size: 9, tracking: 1.5, color: TapePalette.accent)
                }

                progressControl
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TapePalette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(TapePalette.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.38), radius: 22, y: 16)
    }

    private var progressControl: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 3)

                Capsule()
                    .fill(TapePalette.accent)
                    .frame(width: max(3, width * progress), height: 3)

                Circle()
                    .fill(TapePalette.text)
                    .frame(width: 8, height: 8)
                    .offset(x: max(0, width * progress - 4))
                    .shadow(color: .black.opacity(0.4), radius: 4)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        progress = min(1, max(0, value.location.x / width))
                    }
                    .onEnded { _ in
                        haptic(.selection)
                    }
            )
        }
        .frame(height: 20)
        .overlay(alignment: .top) {
            HStack {
                MonospacedLabel(text: timeString(progress), size: 8, tracking: 1.2)
                Spacer()
                MonospacedLabel(text: "04:12", size: 8, tracking: 1.2)
            }
            .offset(y: 14)
        }
        .padding(.bottom, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playback position")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: progress = min(1, progress + 0.05)
            case .decrement: progress = max(0, progress - 0.05)
            @unknown default: break
            }
        }
    }

    private var controlRow: some View {
        HStack(spacing: 0) {
            TransportButton(systemName: "backward.fill", size: 17) {
                haptic(.impact(.light))
            }

            Spacer()

            TransportButton(systemName: isPlaying ? "pause.fill" : "play.fill", size: 23, isPrimary: true) {
                let next = !isPlaying
                withAnimation(.easeOut(duration: next ? 0.75 : 0.45)) {
                    isPlaying = next
                }
                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                    spin += next ? 72 : -18
                }
                haptic(next ? .impact(.medium) : .impact(.light))
            }

            Spacer()

            TransportButton(systemName: "forward.fill", size: 17) {
                haptic(.impact(.light))
                withAnimation(.snappy(duration: 0.28)) {
                    progress = min(1, progress + 0.04)
                    spin += 30
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 18)
    }

    private func timeString(_ value: Double) -> String {
        let totalSeconds = Int(value * 252)
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
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

private struct TransportButton: View {
    let systemName: String
    let size: CGFloat
    var isPrimary = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            pressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                withAnimation(.easeOut(duration: 0.16)) {
                    pressed = false
                }
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(isPrimary ? TapePalette.shell : TapePalette.text)
                .frame(width: isPrimary ? 62 : 46, height: isPrimary ? 62 : 46)
                .background {
                    Circle()
                        .fill(isPrimary ? TapePalette.accent : Color.white.opacity(0.055))
                        .overlay {
                            Circle().stroke(Color.white.opacity(isPrimary ? 0.10 : 0.07), lineWidth: 1)
                        }
                }
                .scaleEffect(pressed ? 0.92 : 1)
                .offset(y: pressed ? 2 : 0)
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
}
