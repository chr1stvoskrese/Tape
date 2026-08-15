import SwiftUI
import UIKit

struct ReelView: View {
    let isPlaying: Bool
    let side: Side

    @State private var rotation: Double = 0

    enum Side {
        case left, right

        var phase: Double {
            switch self {
            case .left: return 0
            case .right: return 48
            }
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: isPlaying ? 1.0 / 30.0 : nil)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let speed: Double = isPlaying ? (side == .left ? 88 : -68) : 0
            let degrees = rotation + (time * speed).truncatingRemainder(dividingBy: 360) + side.phase

            reelBody
                .rotationEffect(.degrees(degrees))
        }
        .onChange(of: isPlaying) { _, playing in
            let generator = UIImpactFeedbackGenerator(style: playing ? .light : .soft)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    private var reelBody: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.09),
                                Color.white.opacity(0.025),
                                Color.black.opacity(0.22)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.66
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.13), lineWidth: max(0.7, size * 0.012))
                    }

                Circle()
                    .stroke(Color.black.opacity(0.28), lineWidth: size * 0.075)
                    .padding(size * 0.095)

                Circle()
                    .stroke(Color.white.opacity(0.055), lineWidth: size * 0.026)
                    .padding(size * 0.18)

                hubSpokes

                Circle()
                    .fill(TapePalette.inset)
                    .frame(width: size * 0.24, height: size * 0.24)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.10), lineWidth: max(0.7, size * 0.01))
                    }

                Circle()
                    .fill(TapePalette.accent.opacity(0.88))
                    .frame(width: size * 0.05, height: size * 0.05)
                    .shadow(color: TapePalette.accent.opacity(0.34), radius: size * 0.045)
            }
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.48), radius: size * 0.10, y: size * 0.06)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var hubSpokes: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Capsule(style: .circular)
                        .fill(Color.white.opacity(0.095))
                        .frame(width: size * 0.026, height: size * 0.23)
                        .offset(y: -size * 0.14)
                        .rotationEffect(.degrees(Double(index) * 72))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TapeGuide: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 7) {
            Capsule()
                .fill(Color.white.opacity(0.09))
                .frame(width: width, height: 2)
            Capsule()
                .fill(TapePalette.accent.opacity(0.18))
                .frame(width: width * 0.72, height: 2)
        }
    }
}
