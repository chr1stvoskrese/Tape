import SwiftUI

struct ReelAssemblyView: View {
    let isPlaying: Bool
    let spin: Double

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let reel = size * 0.27

            ZStack {
                HStack(spacing: size * 0.035) {
                    TapeReel(size: reel, rotation: spin * 0.92, isPlaying: isPlaying)
                    TapeBridge(width: size * 0.17)
                    TapeReel(size: reel, rotation: -spin * 1.18, isPlaying: isPlaying)
                }

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(TapePalette.accent.opacity(0.20))
                        .frame(width: size * 0.19, height: 2)
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(TapePalette.accent.opacity(0.20))
                        .frame(width: size * 0.19, height: 2)
                }
                .frame(width: size * 0.58)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityHidden(true)
    }
}

private struct TapeReel: View {
    let size: CGFloat
    let rotation: Double
    let isPlaying: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.075),
                            Color.white.opacity(0.02),
                            Color.black.opacity(0.20)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.65
                    )
                )
                .overlay(Circle().stroke(TapePalette.line, lineWidth: 1))

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: size * 0.08)
                .padding(size * 0.11)

            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Capsule(style: .circular)
                        .fill(Color.white.opacity(0.10))
                        .frame(width: size * 0.035, height: size * 0.24)
                        .offset(y: -size * 0.15)
                        .rotationEffect(.degrees(Double(index) * 72))
                }
            }
            .rotationEffect(.degrees(rotation))
            .animation(
                isPlaying
                    ? .linear(duration: 1.8).repeatForever(autoreverses: false)
                    : .easeOut(duration: 0.35),
                value: isPlaying
            )

            Circle()
                .fill(TapePalette.inset)
                .frame(width: size * 0.26)
                .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))

            Circle()
                .fill(TapePalette.accent.opacity(0.82))
                .frame(width: size * 0.055)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.35), radius: size * 0.09, y: size * 0.05)
    }
}

private struct TapeBridge: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 7) {
            Capsule()
                .fill(Color.white.opacity(0.07))
                .frame(width: width, height: 2)
            Capsule()
                .fill(TapePalette.accent.opacity(0.12))
                .frame(width: width * 0.72, height: 2)
        }
    }
}
