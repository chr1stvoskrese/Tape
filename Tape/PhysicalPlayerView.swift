import SwiftUI

struct PhysicalPlayerView: View {
    @State private var isPlaying = false
    @State private var volume: Double = 0.72
    @State private var selectedPreset = 0
    @State private var pressedControl: Control?

    var body: some View {
        GeometryReader { proxy in
            let imageAspect: CGFloat = 4.0 / 3.0
            let availableAspect = proxy.size.width / max(proxy.size.height, 1)
            let size: CGSize = availableAspect > imageAspect
                ? CGSize(width: proxy.size.height * imageAspect, height: proxy.size.height)
                : CGSize(width: proxy.size.width, height: proxy.size.width / imageAspect)

            ZStack {
                Color.white.ignoresSafeArea()

                Image("PlayerArtwork")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .overlay {
                        PlayerControlsOverlay(
                            isPlaying: $isPlaying,
                            volume: $volume,
                            selectedPreset: $selectedPreset,
                            pressedControl: $pressedControl
                        )
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .statusBarHidden(true)
    }
}

private struct PlayerControlsOverlay: View {
    @Binding var isPlaying: Bool
    @Binding var volume: Double
    @Binding var selectedPreset: Int
    @Binding var pressedControl: Control?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                hitTarget(.previous, at: point(270, 223, in: proxy.size))
                hitTarget(.rewind, at: point(354, 223, in: proxy.size))
                hitTarget(.fastForward, at: point(439, 223, in: proxy.size))
                hitTarget(.volumeUp, at: point(825, 223, in: proxy.size))
                hitTarget(.volumeDown, at: point(910, 223, in: proxy.size))
                hitTarget(.eqPreset, at: point(995, 223, in: proxy.size))
                hitTarget(.memoryLibrary, at: point(646, 220, in: proxy.size), size: CGSize(width: 180, height: 60))
                hitTarget(.playPause, at: point(397, 754, in: proxy.size), size: CGSize(width: 72, height: 72))
                hitTarget(.next, at: point(903, 754, in: proxy.size), size: CGSize(width: 72, height: 72))
                hitTarget(.power, at: point(1121, 266, in: proxy.size), size: CGSize(width: 58, height: 170))
            }
        }
    }

    private func point(_ x: CGFloat, _ y: CGFloat, in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * x / 1280, y: size.height * y / 960)
    }

    private func hitTarget(_ control: Control, at point: CGPoint, size: CGSize = CGSize(width: 74, height: 74)) -> some View {
        Button {
            trigger(control)
        } label: {
            RoundedRectangle(cornerRadius: min(size.width, size.height) * 0.28, style: .continuous)
                .fill(pressedControl == control ? Color.white.opacity(0.22) : .clear)
                .overlay {
                    RoundedRectangle(cornerRadius: min(size.width, size.height) * 0.28, style: .continuous)
                        .stroke(Color.black.opacity(pressedControl == control ? 0.12 : 0.001), lineWidth: 1)
                }
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(control.accessibilityLabel)
        .position(point)
    }

    private func trigger(_ control: Control) {
        withAnimation(.easeOut(duration: 0.10)) {
            pressedControl = control
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeOut(duration: 0.12)) {
                pressedControl = nil
            }
        }

        switch control {
        case .previous, .rewind, .fastForward, .next:
            Haptics.transport(.skip)
        case .playPause:
            isPlaying.toggle()
            Haptics.transport(isPlaying ? .play : .pause)
        case .volumeDown:
            volume = max(0, volume - 0.08)
            Haptics.scrubTick()
        case .volumeUp:
            volume = min(1, volume + 0.08)
            Haptics.scrubTick()
        case .eqPreset:
            selectedPreset = (selectedPreset + 1) % 4
            Haptics.scrubTick()
        case .memoryLibrary:
            Haptics.scrubTick()
        case .power:
            isPlaying = false
            Haptics.transport(.pause)
        }
    }
}

private enum Control: Hashable {
    case previous
    case rewind
    case playPause
    case fastForward
    case next
    case volumeDown
    case volumeUp
    case eqPreset
    case memoryLibrary
    case power

    var accessibilityLabel: String {
        switch self {
        case .previous: return "Previous"
        case .rewind: return "Rewind"
        case .playPause: return "Play or pause"
        case .fastForward: return "Fast forward"
        case .next: return "Next"
        case .volumeDown: return "Volume down"
        case .volumeUp: return "Volume up"
        case .eqPreset: return "EQ or preset"
        case .memoryLibrary: return "Memory or library"
        case .power: return "Power"
        }
    }
}
