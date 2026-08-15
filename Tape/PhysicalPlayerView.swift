import SwiftUI
import UIKit

struct PhysicalPlayerView: View {
    @State private var isPlaying = false
    @State private var reelPhase: Double = 0
    @State private var pressedControl: Control?
    @State private var progress: CGFloat = 0.38

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()
                player(in: proxy.size)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    private func player(in screenSize: CGSize) -> some View {
        let finalHeight = min(screenSize.height * 0.90, 620)
        let finalWidth = finalHeight * 0.75
        let width = finalHeight
        let height = finalWidth

        return ZStack {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.17, green: 0.17, blue: 0.16),
                            Color(red: 0.06, green: 0.058, blue: 0.054)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 2)
                }

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.025, green: 0.027, blue: 0.025))
                .frame(width: width * 0.70, height: height * 0.56)
                .offset(y: -height * 0.02)

            reelAssembly(width: width, height: height)
            physicalControls(width: width, height: height)
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(90))
        .frame(width: finalWidth, height: finalHeight)
        .shadow(color: .black.opacity(0.44), radius: 28, y: 18)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape music player")
    }

    private func reelAssembly(width: CGFloat, height: CGFloat) -> some View {
        let leftCenter = CGPoint(x: width * 417 / 640, y: height * 438 / 480)
        let rightCenter = CGPoint(x: width * 863 / 640, y: height * 438 / 480)
        let reelSize = width * 318 / 640

        return ZStack {
            Circle()
                .fill(Color(red: 0.14, green: 0.14, blue: 0.14))
                .frame(width: reelSize, height: reelSize)
                .position(leftCenter)

            Circle()
                .fill(Color(red: 1.0, green: 0.45, blue: 0.02))
                .frame(width: reelSize, height: reelSize)
                .position(rightCenter)

            reelCore(size: width * 118 / 640)
                .position(leftCenter)
                .rotationEffect(.degrees(reelPhase))

            reelCore(size: width * 118 / 640)
                .position(rightCenter)
                .rotationEffect(.degrees(-reelPhase * 1.22))
        }
        .allowsHitTesting(false)
    }

    private func reelCore(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.035, green: 0.034, blue: 0.032))
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: max(1, size * 0.02))
                }

            ForEach(0..<5, id: \.self) { index in
                Capsule(style: .circular)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: max(2, size * 0.026), height: size * 0.23)
                    .offset(y: -size * 0.14)
                    .rotationEffect(.degrees(Double(index) * 72))
            }

            Circle()
                .fill(Color(red: 0.025, green: 0.025, blue: 0.023))
                .frame(width: size * 0.24, height: size * 0.24)

            Circle()
                .fill(Color(red: 0.89, green: 0.67, blue: 0.31).opacity(0.9))
                .frame(width: size * 0.05, height: size * 0.05)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private func physicalControls(width: CGFloat, height: CGFloat) -> some View {
        GeometryReader { proxy in
            ZStack {
                controlButton(.previous, x: 267 / 640, y: 222 / 480, width: 72 / 640, height: 58 / 480, in: proxy.size)
                controlButton(.next, x: 355 / 640, y: 222 / 480, width: 72 / 640, height: 58 / 480, in: proxy.size)
                controlButton(.plus, x: 826 / 640, y: 222 / 480, width: 76 / 640, height: 60 / 480, in: proxy.size)
                controlButton(.minus, x: 910 / 640, y: 222 / 480, width: 76 / 640, height: 60 / 480, in: proxy.size)
                controlButton(.eq, x: 990 / 640, y: 222 / 480, width: 72 / 640, height: 60 / 480, in: proxy.size)
                controlButton(.playPause, x: 901 / 640, y: 752 / 480, width: 82 / 640, height: 74 / 480, in: proxy.size)

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 12)
                            .onEnded { value in
                                let dx = value.translation.width
                                let dy = value.translation.height

                                if abs(dx) > abs(dy), abs(dx) > 28 {
                                    trigger(dx < 0 ? .next : .previous)
                                } else if abs(dy) > 22 {
                                    progress = max(0, min(1, progress - dy / 420))
                                    haptic(.selection)
                                }
                            }
                    )
                    .accessibilityLabel("Player surface")
            }
        }
        .frame(width: width, height: height)
    }

    private func controlButton(
        _ control: Control,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        in size: CGSize
    ) -> some View {
        Button {
            trigger(control)
        } label: {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.001))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(pressedControl == control ? 0.10 : 0))
                }
                .scaleEffect(pressedControl == control ? 0.92 : 1)
        }
        .buttonStyle(.plain)
        .frame(width: size.width * width, height: size.height * height)
        .position(x: size.width * x, y: size.height * y)
        .accessibilityLabel(control.label)
    }

    private func trigger(_ control: Control) {
        pressedControl = control
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeOut(duration: 0.12)) {
                pressedControl = nil
            }
        }

        switch control {
        case .playPause:
            isPlaying.toggle()
            if isPlaying {
                withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                    reelPhase += 360
                }
                haptic(.medium)
            } else {
                reelPhase += 24
                haptic(.light)
            }
        case .previous:
            progress = max(0, progress - 0.02)
            reelPhase -= 24
            haptic(.rigid)
        case .next:
            progress = min(1, progress + 0.02)
            reelPhase += 24
            haptic(.rigid)
        case .plus, .minus, .eq:
            haptic(.selection)
        }
    }

    private enum HapticKind {
        case light
        case medium
        case rigid
        case selection
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
        case plus
        case minus
        case eq
        case playPause

        var label: String {
            switch self {
            case .previous: return "Previous track"
            case .next: return "Next track"
            case .plus: return "Volume up"
            case .minus: return "Volume down"
            case .eq: return "Equalizer"
            case .playPause: return "Play or pause"
            }
        }
    }
}

#Preview {
    PhysicalPlayerView()
}
