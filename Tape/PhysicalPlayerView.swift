import SwiftUI

struct PhysicalPlayerView: View {
    @State private var isPlaying = true
    @State private var volume: Double = 0.72
    @State private var selectedPreset = 0
    @State private var pressedControl: Control?

    private let canvas = CGSize(width: 1200, height: 720)

    private let paper = Color(red: 0.965, green: 0.963, blue: 0.950)
    private let surface = Color(red: 0.935, green: 0.930, blue: 0.912)
    private let graphite = Color(red: 0.105, green: 0.105, blue: 0.100)
    private let line = Color(red: 0.16, green: 0.16, blue: 0.15)
    private let muted = Color(red: 0.50, green: 0.49, blue: 0.45)
    private let accent = Color(red: 0.91, green: 0.40, blue: 0.06)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width * 0.94 / canvas.width,
                proxy.size.height * 0.90 / canvas.height
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
            topIdentity
            reelStage
            connectionLines
            controlRail
            bottomInfo
        }
        .frame(width: canvas.width, height: canvas.height)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape hi-fi cassette player")
    }

    // MARK: - Main body

    private var cassetteBody: some View {
        RoundedRectangle(cornerRadius: 42, style: .continuous)
            .fill(surface)
            .overlay {
                RoundedRectangle(cornerRadius: 42, style: .continuous)
                    .stroke(line, lineWidth: 2)
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    Rectangle().fill(accent).frame(width: 34, height: 2)
                    Text("TAPE / 01")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(muted)
                }
                .padding(.leading, 34)
                .padding(.top, 28)
            }
            .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
    }

    private var topIdentity: some View {
        HStack(alignment: .center, spacing: 14) {
            Text(isPlaying ? "PLAY" : "PAUSE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(2.2)
                .foregroundStyle(graphite)

            Circle()
                .fill(isPlaying ? accent : muted.opacity(0.35))
                .frame(width: 7, height: 7)

            Rectangle()
                .fill(line.opacity(0.18))
                .frame(width: 1, height: 28)

            Text("HI-FI / ANALOG TRANSPORT")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(1.7)
                .foregroundStyle(muted)

            Spacer()

            Text("86.4")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(graphite)
            Text("kHz")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(muted)
        }
        .frame(width: 1088)
        .position(x: 600, y: 82)
    }

    // MARK: - Reels

    private var reelStage: some View {
        HStack(spacing: 138) {
            ReelModule(tint: graphite, isPlaying: isPlaying)
                .onTapGesture { togglePlayback() }

            ReelModule(tint: accent, isPlaying: isPlaying)
                .onTapGesture { togglePlayback() }
        }
        .frame(width: 850, height: 430)
        .position(x: 600, y: 342)
    }

    private var connectionLines: some View {
        ZStack {
            Capsule()
                .fill(line.opacity(0.65))
                .frame(width: 280, height: 2)
                .position(x: 600, y: 342)

            Circle()
                .stroke(line.opacity(0.65), lineWidth: 2)
                .frame(width: 12, height: 12)
                .position(x: 600, y: 342)

            Path { path in
                path.move(to: CGPoint(x: 286, y: 190))
                path.addLine(to: CGPoint(x: 286, y: 493))
            }
            .stroke(line.opacity(0.16), style: StrokeStyle(lineWidth: 1, dash: [5, 8]))

            Path { path in
                path.move(to: CGPoint(x: 914, y: 190))
                path.addLine(to: CGPoint(x: 914, y: 493))
            }
            .stroke(line.opacity(0.16), style: StrokeStyle(lineWidth: 1, dash: [5, 8]))
        }
        .allowsHitTesting(false)
    }

    // MARK: - Controls

    private var controlRail: some View {
        HStack(spacing: 10) {
            control(.previous, title: "PREV", symbol: "backward.end")
            control(.rewind, title: "REW", symbol: "backward")
            control(.playPause, title: isPlaying ? "PAUSE" : "PLAY", symbol: isPlaying ? "pause" : "play")
            control(.forward, title: "FWD", symbol: "forward")
            control(.volumeDown, title: "VOL−", symbol: "minus")
            control(.volumeUp, title: "VOL+", symbol: "plus")
            control(.preset, title: "PRESET", symbol: "slider.horizontal.3")
            control(.power, title: "POWER", symbol: "power")
        }
        .frame(height: 72)
        .position(x: 600, y: 565)
    }

    private func control(_ control: Control, title: String, symbol: String) -> some View {
        Button {
            trigger(control)
        } label: {
            VStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .medium))
                    .frame(height: 17)

                Text(title)
                    .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                    .tracking(0.7)
            }
            .foregroundStyle(control == .power ? accent : graphite)
            .frame(width: 76, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(paper.opacity(0.78))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(line.opacity(control == .power ? 0.35 : 0.18), lineWidth: 1)
            }
            .scaleEffect(pressedControl == control ? 0.94 : 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom information

    private var bottomInfo: some View {
        HStack(alignment: .center, spacing: 28) {
            Text("MEMORY")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(muted)

            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(index == selectedPreset ? accent : line.opacity(0.24))
                        .frame(width: 22, height: 2)
                }
            }

            Text("P0\(selectedPreset + 1)")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(graphite)

            Spacer()

            HStack(spacing: 8) {
                Text("VOLUME")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(muted)

                Capsule()
                    .fill(line.opacity(0.18))
                    .frame(width: 110, height: 2)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(accent)
                            .frame(width: 110 * volume, height: 2)
                    }

                Text("\(Int(volume * 100))")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(graphite)
                    .frame(width: 28, alignment: .trailing)
            }
        }
        .frame(width: 1088)
        .position(x: 600, y: 658)
    }

    // MARK: - Interaction

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
        case previous
        case rewind
        case playPause
        case forward
        case volumeDown
        case volumeUp
        case preset
        case power
    }
}

private struct ReelModule: View {
    let tint: Color
    let isPlaying: Bool

    var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let seconds = context.date.timeIntervalSinceReferenceDate
            let rotation = (seconds * 34).truncatingRemainder(dividingBy: 360)

            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 330, height: 330)
                    .overlay {
                        Circle()
                            .stroke(Color.black.opacity(0.16), lineWidth: 1)
                    }

                Circle()
                    .fill(tint.opacity(0.08))
                    .frame(width: 300, height: 300)

                Circle()
                    .stroke(tint.opacity(0.28), lineWidth: 1)
                    .frame(width: 258, height: 258)

                ForEach(0..<6, id: \.self) { index in
                    Capsule()
                        .fill(tint.opacity(0.70))
                        .frame(width: 7, height: 78)
                        .offset(y: -74)
                        .rotationEffect(.degrees(Double(index) * 60))
                }

                Circle()
                    .fill(tint.opacity(0.05))
                    .frame(width: 128, height: 128)
                    .overlay {
                        Circle()
                            .stroke(tint.opacity(0.45), lineWidth: 1.5)
                    }

                Circle()
                    .fill(tint)
                    .frame(width: 34, height: 34)

                Circle()
                    .fill(paper)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 330, height: 330)
            .rotationEffect(.degrees(rotation))
        }
    }
}
