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
        let sourceWidth = finalHeight
        let sourceHeight = finalWidth

        return ZStack {
            Image(uiImage: ReferenceArtwork2.image)
                .resizable()
                .scaledToFill()
                .frame(width: sourceWidth, height: sourceHeight)

            animatedReelCores(sourceWidth: sourceWidth, sourceHeight: sourceHeight)
            physicalControls(sourceWidth: sourceWidth, sourceHeight: sourceHeight)
        }
        .frame(width: sourceWidth, height: sourceHeight)
        .rotationEffect(.degrees(90))
        .frame(width: finalWidth, height: finalHeight)
        .shadow(color: .black.opacity(0.44), radius: 28, y: 18)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape music player")
    }

    private func animatedReelCores(sourceWidth: CGFloat, sourceHeight: CGFloat) -> some View {
        let leftCenter = CGPoint(x: sourceWidth * 417 / 640, y: sourceHeight * 438 / 480)
        let rightCenter = CGPoint(x: sourceWidth * 863 / 640, y: sourceHeight * 438 / 480)
        let coreSize = sourceWidth * 118 / 640

        return ZStack {
            Circle()
                .fill(Color(red: 0.14, green: 0.14, blue: 0.14))
                .frame(width: sourceWidth * 318 / 640, height: sourceWidth * 318 / 640)
                .position(leftCenter)

            Circle()
                .fill(Color(red: 1.0, green: 0.45, blue: 0.02))
                .frame(width: sourceWidth * 318 / 640, height: sourceWidth * 318 / 640)
                .position(rightCenter)

            reelCore(crop: CGRect(x: 352, y: 373, width: 118, height: 118), size: coreSize)
                .position(leftCenter)
                .rotationEffect(.degrees(reelPhase), anchor: .center)

            reelCore(crop: CGRect(x: 804, y: 373, width: 118, height: 118), size: coreSize)
                .position(rightCenter)
                .rotationEffect(.degrees(-reelPhase * 1.22), anchor: .center)
        }
        .allowsHitTesting(false)
        .opacity(isPlaying ? 1 : 0.98)
    }

    private func reelCore(crop: CGRect, size: CGFloat) -> some View {
        let cropped = ReferenceArtwork2.image.cgImage.flatMap { $0.cropping(to: crop) }.map(UIImage.init)
        return Group {
            if let cropped {
                Image(uiImage: cropped)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            }
        }
    }

    private func physicalControls(sourceWidth: CGFloat, sourceHeight: CGFloat) -> some View {
        GeometryReader { proxy in
            ZStack {
                controlButton(.previous, x: 267 / 640, y: 222 / 480, width: 72 / 640, height: 58 / 480, in: proxy.size)
                controlButton(.next, x: 355 / 640, y: 222 / 480, width: 72 / 640, height: 58 / 480, in: proxy.size)
                controlButton(.plus, x: 826 / 640, y: 222 / 480, width: 76 / 640, height: 60 / 480, in: proxy.size)
                controlButton(.minus, x: 910 / 640, y: 222 / 480, width: 76 / 640, height: 60 / 480, in: proxy.size)
                controlButton(.eq, x: 990 / 640, y: 222 / 480, width: 72 / 640, height: 60 / 480, in: proxy.size)
                controlButton(.playPause, x: 901 / 640, y: 752 / 480, width: 82 / 640, height: 74 / 480, in: proxy.size)

                Rectangle()
                    .fill(.clear)
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
                    .allowsHitTesting(false)
            }
        }
        .frame(width: sourceWidth, height: sourceHeight)
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
                .fill(.clear)
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
            withAnimation(.easeOut(duration: 0.12)) { pressedControl = nil }
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

    private enum HapticKind { case light, medium, rigid, selection }

    private func haptic(_ kind: HapticKind) {
        switch kind {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare(); generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare(); generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare(); generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare(); generator.selectionChanged()
        }
    }

    private enum Control: Hashable {
        case previous, next, plus, minus, eq, playPause

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

#Preview(traits: .landscapeLeft) {
    PhysicalPlayerView()
}
