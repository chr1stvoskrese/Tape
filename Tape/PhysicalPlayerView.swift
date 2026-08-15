import SwiftUI
import UIKit

struct PhysicalPlayerView: View {
    @State private var isPlaying = true
    @State private var volume: Double = 0.72
    @State private var selectedPreset = 0
    @State private var pressedControl: Control?

    var body: some View {
        GeometryReader { proxy in
            let width = min(proxy.size.width * 0.96, proxy.size.height * 1.78)
            let height = width / PlayerArtwork.aspectRatio

            ZStack {
                Color(red: 0.962, green: 0.958, blue: 0.946)
                    .ignoresSafeArea()

                PlayerArtwork(
                    isPlaying: isPlaying,
                    leftReelSpeed: 32,
                    rightReelSpeed: -46
                )
                .frame(width: width, height: height)
                .overlay {
                    controlsOverlay
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(.light)
        .statusBarHidden(true)
    }

    private var controlsOverlay: some View {
        GeometryReader { proxy in
            ZStack {
                control(.previous, symbol: "backward.end.fill")
                    .position(x: proxy.size.width * 0.196, y: proxy.size.height * 0.805)
                control(.rewind, symbol: "backward.fill")
                    .position(x: proxy.size.width * 0.283, y: proxy.size.height * 0.805)
                control(.playPause, symbol: isPlaying ? "pause.fill" : "play.fill", emphasis: true)
                    .position(x: proxy.size.width * 0.500, y: proxy.size.height * 0.805)
                control(.fastForward, symbol: "forward.fill")
                    .position(x: proxy.size.width * 0.717, y: proxy.size.height * 0.805)
                control(.next, symbol: "forward.end.fill")
                    .position(x: proxy.size.width * 0.804, y: proxy.size.height * 0.805)

                control(.volumeDown, symbol: "speaker.wave.1.fill", compact: true)
                    .position(x: proxy.size.width * 0.105, y: proxy.size.height * 0.185)
                control(.volumeUp, symbol: "speaker.wave.3.fill", compact: true)
                    .position(x: proxy.size.width * 0.895, y: proxy.size.height * 0.185)
                control(.eqPreset, symbol: "slider.horizontal.3", compact: true)
                    .position(x: proxy.size.width * 0.105, y: proxy.size.height * 0.815)
                control(.memoryLibrary, symbol: "rectangle.stack.fill", compact: true)
                    .position(x: proxy.size.width * 0.895, y: proxy.size.height * 0.815)
                control(.power, symbol: "power", compact: true, accent: true)
                    .position(x: proxy.size.width * 0.500, y: proxy.size.height * 0.132)
            }
        }
    }

    private func control(
        _ control: Control,
        symbol: String,
        emphasis: Bool = false,
        compact: Bool = false,
        accent: Bool = false
    ) -> some View {
        Button {
            trigger(control)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: compact ? 13 : (emphasis ? 20 : 15), weight: .semibold))
                .foregroundStyle(accent ? Color(red: 0.90, green: 0.34, blue: 0.12) : Color.black.opacity(0.78))
                .frame(width: compact ? 42 : (emphasis ? 72 : 56), height: compact ? 42 : (emphasis ? 64 : 56))
                .background {
                    Circle()
                        .fill(Color.white.opacity(emphasis ? 0.76 : 0.001))
                }
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(emphasis ? 0.18 : 0.001), lineWidth: 1)
                }
                .contentShape(Circle())
                .scaleEffect(pressedControl == control ? 0.90 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(control.accessibilityLabel)
    }

    private func togglePlayback() {
        isPlaying.toggle()
        Haptics.transport(isPlaying ? .play : .pause)
    }

    private func trigger(_ control: Control) {
        withAnimation(.easeOut(duration: 0.12)) {
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
            togglePlayback()
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
}

private struct PlayerArtwork: View {
    static let aspectRatio: CGFloat = 1.68

    let isPlaying: Bool
    let leftReelSpeed: Double
    let rightReelSpeed: Double

    private let ink = Color(red: 0.095, green: 0.092, blue: 0.086)
    private let accent = Color(red: 0.90, green: 0.34, blue: 0.12)

    var body: some View {
        GeometryReader { proxy in
            let reelSize = proxy.size.height * 0.57

            ZStack {
                RoundedRectangle(cornerRadius: proxy.size.height * 0.072, style: .continuous)
                    .fill(Color(red: 0.90, green: 0.885, blue: 0.85))
                    .overlay {
                        RoundedRectangle(cornerRadius: proxy.size.height * 0.072, style: .continuous)
                            .stroke(ink.opacity(0.72), lineWidth: 1.5)
                    }

                RoundedRectangle(cornerRadius: proxy.size.height * 0.058, style: .continuous)
                    .stroke(Color.white.opacity(0.58), lineWidth: 1)
                    .padding(proxy.size.height * 0.022)

                HStack(spacing: proxy.size.width * 0.095) {
                    ReelArtwork(ink: ink, accent: accent, speed: leftReelSpeed, isPlaying: isPlaying, phase: 0)
                        .frame(width: reelSize, height: reelSize)
                    ReelArtwork(ink: ink, accent: accent, speed: rightReelSpeed, isPlaying: isPlaying, phase: 62)
                        .frame(width: reelSize, height: reelSize)
                }
                .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.48)

                Capsule()
                    .fill(ink.opacity(0.38))
                    .frame(width: proxy.size.width * 0.15, height: 1)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.48)

                Circle()
                    .fill(Color(red: 0.90, green: 0.885, blue: 0.85))
                    .frame(width: proxy.size.height * 0.045, height: proxy.size.height * 0.045)
                    .overlay(Circle().stroke(ink.opacity(0.48), lineWidth: 1))
                    .overlay(Circle().fill(accent).frame(width: proxy.size.height * 0.012, height: proxy.size.height * 0.012))
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.48)

                topDetails(size: proxy.size)
                bottomRail(size: proxy.size)
            }
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tape hi-fi cassette transport")
    }

    @ViewBuilder
    private func topDetails(size: CGSize) -> some View {
        HStack {
            Text("TAPE")
                .font(.system(size: size.height * 0.030, weight: .bold, design: .rounded))
                .tracking(size.height * 0.010)
            Spacer()
            Capsule().fill(accent).frame(width: size.width * 0.065, height: 3)
        }
        .foregroundStyle(ink)
        .frame(width: size.width * 0.76)
        .position(x: size.width * 0.5, y: size.height * 0.10)
    }

    @ViewBuilder
    private func bottomRail(size: CGSize) -> some View {
        Capsule()
            .fill(ink.opacity(0.14))
            .frame(width: size.width * 0.64, height: 1)
            .position(x: size.width * 0.5, y: size.height * 0.69)
    }
}

private struct ReelArtwork: View {
    let ink: Color
    let accent: Color
    let speed: Double
    let isPlaying: Bool
    let phase: Double

    var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let angle = isPlaying ? (time * speed + phase).truncatingRemainder(dividingBy: 360) : phase

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.38))
                    .overlay(Circle().stroke(ink.opacity(0.16), lineWidth: 1))

                Circle()
                    .stroke(ink.opacity(0.23), lineWidth: 1.4)
                    .padding(7)

                Circle()
                    .stroke(ink.opacity(0.10), lineWidth: 1)
                    .padding(20)

                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(ink.opacity(0.64))
                        .frame(width: 7, height: 66)
                        .offset(y: -58)
                        .rotationEffect(.degrees(Double(index) * 60))
                }

                Circle()
                    .fill(ink.opacity(0.045))
                    .frame(width: 112, height: 112)
                    .overlay(Circle().stroke(ink.opacity(0.30), lineWidth: 1.2))

                Circle()
                    .fill(ink)
                    .frame(width: 31, height: 31)
                Circle()
                    .fill(Color.white)
                    .frame(width: 9, height: 9)

                Capsule()
                    .fill(accent.opacity(0.62))
                    .frame(width: 2, height: 32)
                    .offset(y: -94)
            }
            .rotationEffect(.degrees(angle))
        }
    }
}
