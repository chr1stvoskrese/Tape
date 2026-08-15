import SwiftUI
import UIKit

struct PhysicalPlayerView: View {
    @State private var isPlaying = false
    @State private var reelPhase: Double = 0
    @State private var pressedControl: Control? = nil
    @State private var progress: CGFloat = 0.38

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()
                playerObject(in: proxy.size)
                    .contentShape(Rectangle())
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    private func playerObject(in size: CGSize) -> some View {
        let height = min(size.height * 0.90, 620)
        let width = height * 0.75

        return ZStack {
            Image(uiImage: ReferenceArtwork2.image)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .rotationEffect(.degrees(90))
                .shadow(color: .black.opacity(0.42), radius: 30, y: 18)

            rotatingReelOverlays(width: width, height: height)
            interactionSurface(width: width, height: height)
        }
        .frame(width: width, height: height)
        .animation(.easeInOut(duration: 0.35), value: isPlaying)
    }

    private func rotatingReelOverlays(width: CGFloat, height: CGFloat) -> some View {
        GeometryReader { _ in
            let discSize = min(width, height) * 0.27
            let offsetX = height * 0.285
            let offsetY = -width * 0.065

            ZStack {
                reelCrop(.left, size: discSize)
                    .offset(x: offsetY, y: -offsetX)
                    .rotationEffect(.degrees(reelPhase))

                reelCrop(.right, size: discSize)
                    .offset(x: offsetY, y: offsetX)
                    .rotationEffect(.degrees(-reelPhase * 1.22))
            }
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
        .opacity(isPlaying ? 1 : 0.96)
    }

    private enum ReelSide { case left, right }

    private func reelCrop(_ side: ReelSide, size: CGFloat) -> some View {
        let source = side == .left
            ? CGRect(x: 185, y: 205, width: 150, height: 150)
            : CGRect(x: 530, y: 205, width: 150, height: 150)

        let cropped = ReferenceArtwork2.image.cgImage.flatMap { $0.cropping(to: source) }.map(UIImage.init)

        return Group {
            if let cropped {
                Image(uiImage: cropped)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            }
        }
    }

    private func interactionSurface(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            buttonZone(x: 0.22, y: 0.14, width: 0.12, height: 0.09, control: .previous)
            buttonZone(x: 0.39, y: 0.14, width: 0.12, height: 0.09, control: .next)
            buttonZone(x: 0.73, y: 0.14, width: 0.11, height: 0.09, control: .plus)
            buttonZone(x: 0.84, y: 0.14, width: 0.11, height: 0.09, control: .minus)
            buttonZone(x: 0.94, y: 0.14, width: 0.10, height: 0.09, control: .eq)
            buttonZone(x: 0.70, y: 0.78, width: 0.14, height: 0.13, control: .playPause)

            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
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
        .frame(width: width, height: height)
    }

    private func buttonZone(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, control: Control) -> some View {
        Button {
            trigger(control)
        } label: {
            Color.clear
                .frame(width: 1, height: 1)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: width * 1000, height: height * 1000)
        .scaleEffect(pressedControl == control ? 0.92 : 1)
        .position(x: x * 1000, y: y * 1000)
        .accessibilityLabel(control.label)
    }

    private func trigger(_ control: Control) {
        pressedControl = control
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
            withAnimation(.easeOut(duration: 0.12)) { pressedControl = nil }
        }

        switch control {
        case .playPause:
            isPlaying.toggle()
            if isPlaying {
                withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                    reelPhase += 360
                }
                haptic(.medium)
            } else {
                reelPhase += 24
                haptic(.light)
            }
        case .previous:
            progress = max(0, progress - 0.02)
            reelPhase -= 20
            haptic(.rigid)
        case .next:
            progress = min(1, progress + 0.02)
            reelPhase += 20
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
