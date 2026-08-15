import SwiftUI
import UIKit

struct PhysicalPlayerView: View {
    @State private var isPlaying = true
    @State private var volume: Double = 0.72
    @State private var selectedPreset = 0
    @State private var pressedControl: Control?

    private let canvas = CGSize(width: 1280, height: 800)
    private let paper = Color(red: 0.965, green: 0.963, blue: 0.950)
    private let surface = Color(red: 0.945, green: 0.940, blue: 0.925)
    private let white = Color(red: 0.985, green: 0.982, blue: 0.973)
    private let graphite = Color(red: 0.105, green: 0.105, blue: 0.100)
    private let line = Color(red: 0.18, green: 0.18, blue: 0.17)
    private let muted = Color(red: 0.48, green: 0.47, blue: 0.44)
    private let accent = Color(red: 0.91, green: 0.40, blue: 0.06)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width * 0.985 / canvas.width,
                proxy.size.height * 0.94 / canvas.height
            )

            ZStack {
                paper.ignoresSafeArea()
                player
                    .scaleEffect(scale)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden(true)
    }

    private var player: some View {
        ZStack {
            cassetteBody
            header
            reelStage
            centerSpine
            controls
            telemetry
        }
        .frame(width: canvas.width, height: canvas.height)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape hi-fi cassette player")
    }

    private var cassetteBody: some View {
        RoundedRectangle(cornerRadius: 48, style: .continuous)
            .fill(surface)
            .overlay {
                RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .stroke(line.opacity(0.82), lineWidth: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    .padding(10)
            }
            .shadow(color: .black.opacity(0.07), radius: 18, y: 10)
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                Capsule()
                    .fill(accent)
                    .frame(width: 36, height: 3)
                Text("TAPE")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(graphite)
                Text("/ 01")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(muted)
            }

            Spacer()

            HStack(spacing: 10) {
                Circle()
                    .fill(isPlaying ? accent : muted.opacity(0.28))
                    .frame(width: 8, height: 8)
                Text(isPlaying ? "PLAYING" : "PAUSED")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.8)
                    .foregroundStyle(graphite)
            }
        }
        .frame(width: 1140)
        .position(x: 640, y: 76)
    }

    private var reelStage: some View {
        HStack(spacing: 150) {
            ReelModule(tint: graphite, accent: accent, isPlaying: isPlaying)
                .onTapGesture { togglePlayback() }

            ReelModule(tint: accent, accent: accent, isPlaying: isPlaying)
                .onTapGesture { togglePlayback() }
        }
        .frame(width: 1030, height: 440)
        .position(x: 640, y: 342)
    }

    private var centerSpine: some View {
        ZStack {
            Capsule()
                .fill(line.opacity(0.62))
                .frame(width: 220, height: 1.5)

            Circle()
                .fill(surface)
                .frame(width: 34, height: 34)
                .overlay {
                    Circle()
                        .stroke(line.opacity(0.55), lineWidth: 1.5)
                }
                .overlay {
                    Circle()
                        .fill(accent)
                        .frame(width: 7, height: 7)
                }
        }
        .position(x: 640, y: 342)
        .allowsHitTesting(false)
    }

    private var controls: some View {
        HStack(spacing: 14) {
            control(.previous, symbol: "backward.end.fill", title: "PREV")
            control(.rewind, symbol: "backward.fill", title: "REW")
            control(.playPause, symbol: isPlaying ? "pause.fill" : "play.fill", title: isPlaying ? "PAUSE" : "PLAY", emphasis: true)
            control(.forward, symbol: "forward.fill", title: "FWD")
            control(.volumeDown, symbol: "minus", title: "VOL −")
            control(.volumeUp, symbol: "plus", title: "VOL +")
            control(.preset, symbol: "slider.horizontal.3", title: "PRESET")
            control(.power, symbol: "power", title: "POWER", accentText: true)
        }
        .frame(height: 84)
        .position(x: 640, y: 594)
    }

    private func control(
        _ control: Control,
        symbol: String,
        title: String,
        emphasis: Bool = false,
        accentText: Bool = false
    ) -> some View {
        Button {
            trigger(control)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: emphasis ? 20 : 15, weight: emphasis ? .semibold : .medium))
                    .frame(height: 20)

                Text(title)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.9)
            }
            .foregroundStyle(accentText ? accent : graphite)
            .frame(width: emphasis ? 92 : 84, height: emphasis ? 74 : 70)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(emphasis ? white : paper.opacity(0.74))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(emphasis ? line.opacity(0.28) : line.opacity(0.14), lineWidth: 1)
            }
            .shadow(color: emphasis ? .black.opacity(0.06) : .clear, radius: 8, y: 4)
            .scaleEffect(pressedControl == control ? 0.94 : 1)
        }
        .buttonStyle(.plain)
    }

    private var telemetry: some View {
        HStack(alignment: .center, spacing: 28) {
            HStack(spacing: 14) {
                Text("MEM")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(muted)

                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index == selectedPreset ? accent : line.opacity(0.18))
                            .frame(width: 24, height: 2.5)
                    }
                }

                Text("P0\(selectedPreset + 1)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(graphite)
            }

            Rectangle()
                .fill(line.opacity(0.12))
                .frame(width: 1, height: 24)

            HStack(spacing: 10) {
                Text("OUT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(muted)

                Capsule()
                    .fill(line.opacity(0.14))
                    .frame(width: 160, height: 3)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(accent)
                            .frame(width: 160 * volume, height: 3)
                    }

                Text(String(format: "%02d", Int(volume * 100)))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(graphite)
                    .frame(width: 22, alignment: .trailing)
            }

            Spacer(minLength: 0)

            Text("ANALOG / TRANSPORT")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .tracking(1.6)
                .foregroundStyle(muted)
        }
        .frame(width: 1140)
        .position(x: 640, y: 700)
    }

    private func togglePlayback() {
        isPlaying.toggle()
        Haptics.transport(isPlaying ? .play : .pause)
    }

    private func trigger(_ control: Control) {
        pressedControl = control
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            withAnimation(.easeOut(duration: 0.12)) {
                pressedControl = nil
            }
        }

        switch control {
        case .previous, .rewind, .forward:
            Haptics.transport(.skip)
        case .playPause:
            togglePlayback()
        case .volumeDown:
            volume = max(0, volume - 0.08)
            Haptics.scrubTick()
        case .volumeUp:
            volume = min(1, volume + 0.08)
            Haptics.scrubTick()
        case .preset:
            selectedPreset = (selectedPreset + 1) % 4
            Haptics.scrubTick()
        case .power:
            isPlaying = false
            Haptics.transport(.pause)
        }
    }

    private enum Control: Hashable {
        case previous, rewind, playPause, forward
        case volumeDown, volumeUp, preset, power
    }
}

private struct ReelModule: View {
    let tint: Color
    let accent: Color
    let isPlaying: Bool

    var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let seconds = context.date.timeIntervalSinceReferenceDate
            let rotation = (seconds * 34).truncatingRemainder(dividingBy: 360)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.34))
                    .frame(width: 386, height: 386)
                    .overlay {
                        Circle()
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    }

                Circle()
                    .fill(tint.opacity(0.035))
                    .frame(width: 352, height: 352)

                Circle()
                    .stroke(tint.opacity(0.24), lineWidth: 1.5)
                    .frame(width: 300, height: 300)

                Circle()
                    .stroke(tint.opacity(0.10), lineWidth: 1)
                    .frame(width: 244, height: 244)

                ForEach(0..<6, id: \.self) { index in
                    Capsule()
                        .fill(tint.opacity(0.70))
                        .frame(width: 8, height: 84)
                        .offset(y: -76)
                        .rotationEffect(.degrees(Double(index) * 60))
                }

                Circle()
                    .fill(tint.opacity(0.035))
                    .frame(width: 132, height: 132)
                    .overlay {
                        Circle()
                            .stroke(tint.opacity(0.32), lineWidth: 1.5)
                    }

                Circle()
                    .fill(tint)
                    .frame(width: 38, height: 38)

                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)

                // Minimal tone-arm marker / sensor line.
                Capsule()
                    .fill(accent.opacity(0.55))
                    .frame(width: 2, height: 48)
                    .offset(y: -174)
            }
            .frame(width: 386, height: 386)
            .rotationEffect(.degrees(rotation))
        }
    }
}
