import SwiftUI

struct PhysicalPlayerView: View {
    @State private var isPlaying = true
    @State private var volume: Double = 0.72
    @State private var selectedPreset = 0
    @State private var pressedControl: Control?

    private let backdrop = Color(red: 0.965, green: 0.965, blue: 0.955)
    private let cream = Color(red: 0.949, green: 0.933, blue: 0.886)
    private let ink = Color(red: 0.10, green: 0.10, blue: 0.10)
    private let olive = Color(red: 0.66, green: 0.63, blue: 0.47)
    private let orange = Color(red: 0.93, green: 0.42, blue: 0.06)
    private let hubRing = Color(red: 0.85, green: 0.83, blue: 0.77)

    private let designSize = CGSize(width: 1000, height: 620)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width * 0.94 / designSize.width,
                proxy.size.height * 0.90 / designSize.height
            )

            ZStack {
                backdrop.ignoresSafeArea()

                deck
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(180))
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden(true)
    }

    private var deck: some View {
        ZStack {
            bodyShell
            topNotch
            reelsAndArms
            dashes
            transportButtons
            memoryLabel
            orangeButtons
            onOff
            bottomPlate
        }
        .frame(width: designSize.width, height: designSize.height)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape physical music player")
    }

    private var bodyShell: some View {
        RoundedRectangle(cornerRadius: 38, style: .continuous)
            .fill(cream)
            .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .stroke(ink, lineWidth: 4)
            }
    }

    private var topNotch: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(cream)
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(ink, lineWidth: 4)
                }
                .frame(width: 160, height: 16)

            Rectangle()
                .fill(cream)
                .frame(width: 148, height: 10)
                .offset(y: 6)
        }
        .position(x: 495, y: 0)
    }

    private var dashes: some View {
        ForEach(0..<2, id: \.self) { i in
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(olive)
                .frame(width: 26, height: 8)
                .position(x: 80, y: 50 + CGFloat(i) * 28)
        }
    }

    private var transportButtons: some View {
        let items: [(Control, String)] = [
            (.previous, "backward.end.fill"),
            (.rewind, "backward.fill"),
            (.forward, "forward.fill")
        ]

        return ForEach(0..<items.count, id: \.self) { i in
            circleControl(items[i].0, fill: ink) {
                Image(systemName: items[i].1)
                    .font(.system(size: 18, weight: .bold))
            }
            .position(x: 146 + CGFloat(i) * 92, y: 62)
        }
    }

    private var memoryLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 11))
            Text("Memory card")
                .font(.system(size: 18, weight: .bold))
        }
        .foregroundStyle(ink)
        .position(x: 495, y: 62)
    }

    private var orangeButtons: some View {
        Group {
            circleControl(.volumeUp, fill: orange) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
            }
            .position(x: 677, y: 62)

            circleControl(.volumeDown, fill: orange) {
                Image(systemName: "minus")
                    .font(.system(size: 18, weight: .bold))
            }
            .position(x: 768, y: 62)

            circleControl(.eq, fill: orange) {
                Text("EQ")
                    .font(.system(size: 15, weight: .bold))
            }
            .position(x: 858, y: 62)
        }
    }

    private var onOff: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.up")
                .font(.system(size: 12, weight: .heavy))
            Text("On")
                .font(.system(size: 16, weight: .bold))
                .fixedSize()
                .rotationEffect(.degrees(90))
                .frame(width: 20, height: 30)
            Text("Off")
                .font(.system(size: 16, weight: .bold))
                .fixedSize()
                .rotationEffect(.degrees(90))
                .frame(width: 20, height: 34)
            Image(systemName: "arrow.down")
                .font(.system(size: 12, weight: .heavy))
        }
        .foregroundStyle(ink)
        .position(x: 952, y: 105)
    }

    private var reelsAndArms: some View {
        ZStack {
            reel(tape: ink, center: CGPoint(x: 288, y: 258))
            reel(tape: orange, center: CGPoint(x: 712, y: 258))

            toneArm(
                pivot: CGPoint(x: 98, y: 358),
                elbow: CGPoint(x: 150, y: 252),
                tip: CGPoint(x: 198, y: 192),
                head: CGPoint(x: 207, y: 178),
                headAngle: 40,
                color: ink
            )

            toneArm(
                pivot: CGPoint(x: 800, y: 345),
                elbow: CGPoint(x: 752, y: 248),
                tip: CGPoint(x: 762, y: 188),
                head: CGPoint(x: 768, y: 172),
                headAngle: -40,
                color: orange
            )
        }
        .allowsHitTesting(false)
    }

    private func reel(tape: Color, center: CGPoint) -> some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let degrees = (t * 42).truncatingRemainder(dividingBy: 360)

            ZStack {
                Circle()
                    .fill(tape)
                    .shadow(color: .black.opacity(0.18), radius: 5, x: 3, y: 4)
                Circle().stroke(ink, lineWidth: 3)

                Circle()
                    .fill(hubRing)
                    .frame(width: 112, height: 112)
                    .overlay {
                        Circle().stroke(ink, lineWidth: 2)
                    }

                Circle()
                    .fill(.white)
                    .frame(width: 84, height: 84)

                ForEach(0..<6, id: \.self) { i in
                    Rectangle()
                        .fill(hubRing)
                        .frame(width: 15, height: 24)
                        .offset(y: -42)
                        .rotationEffect(.degrees(Double(i) * 60))
                }
            }
            .frame(width: 300, height: 300)
            .rotationEffect(.degrees(degrees))
            .contentShape(Circle())
            .position(center)
            .onTapGesture {
                isPlaying.toggle()
                Haptics.transport(isPlaying ? .play : .pause)
            }
        }
    }

    private func toneArm(
        pivot: CGPoint,
        elbow: CGPoint,
        tip: CGPoint,
        head: CGPoint,
        headAngle: Double,
        color: Color
    ) -> some View {
        ZStack {
            Path { p in
                p.move(to: pivot)
                p.addLine(to: elbow)
                p.addLine(to: tip)
            }
            .stroke(ink, style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))

            Path { p in
                p.move(to: pivot)
                p.addLine(to: elbow)
                p.addLine(to: tip)
            }
            .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(ink, lineWidth: 3)
                }
                .overlay {
                    Capsule()
                        .fill(ink.opacity(0.85))
                        .frame(width: 4, height: 18)
                }
                .frame(width: 26, height: 46)
                .rotationEffect(.degrees(headAngle))
                .position(head)

            ZStack {
                Circle()
                    .fill(color)
                    .shadow(color: .black.opacity(0.18), radius: 3, x: 2, y: 3)
                Circle().stroke(.white, lineWidth: 5).padding(6)
                Circle().stroke(ink, lineWidth: 3)
            }
            .frame(width: 80, height: 80)
            .position(pivot)
        }
    }

    private var bottomPlate: some View {
        ZStack {
            TrapezoidPanel(topInset: 0.045)
                .fill(cream)
                .shadow(color: .black.opacity(0.10), radius: 4, y: 3)
                .overlay {
                    TrapezoidPanel(topInset: 0.045)
                        .stroke(ink, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                }
                .frame(width: 675, height: 145)
                .position(x: 507, y: 522)

            Circle()
                .fill(.white)
                .frame(width: 40, height: 40)
                .overlay { Circle().stroke(ink, lineWidth: 3) }
                .position(x: 265, y: 550)

            oliveSlot
                .position(x: 365, y: 550)

            oliveSlot
                .position(x: 640, y: 550)

            ZStack {
                Circle().fill(ink).frame(width: 40, height: 40)
                Circle().stroke(.white, lineWidth: 6).frame(width: 22, height: 22)
            }
            .position(x: 740, y: 550)

            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(olive)
                .frame(width: 50, height: 14)
                .position(x: 905, y: 550)
        }
        .allowsHitTesting(false)
    }

    private var oliveSlot: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(olive)
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(ink, lineWidth: 2.5)
            }
            .frame(width: 36, height: 28)
    }

    private func circleControl(
        _ control: Control,
        fill: Color,
        @ViewBuilder content: () -> some View
    ) -> some View {
        Button {
            trigger(control)
        } label: {
            ZStack {
                Circle()
                    .fill(fill)
                    .shadow(color: .black.opacity(0.22), radius: 3, x: 2, y: 3)
                Circle()
                    .stroke(ink, lineWidth: 2.5)
                content()
                    .foregroundStyle(.white)
            }
            .frame(width: 52, height: 52)
            .scaleEffect(pressedControl == control ? 0.92 : 1)
        }
        .buttonStyle(.plain)
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
        case .volumeDown:
            volume = max(0, volume - 0.08)
            Haptics.scrubTick()
        case .volumeUp:
            volume = min(1, volume + 0.08)
            Haptics.scrubTick()
        case .eq:
            selectedPreset = (selectedPreset + 1) % 4
            Haptics.scrubTick()
        }
    }

    private enum Control: Hashable {
        case previous, rewind, forward
        case volumeUp, volumeDown
        case eq
    }
}

struct TrapezoidPanel: Shape {
    var topInset: CGFloat

    func path(in rect: CGRect) -> Path {
        let inset = rect.width * topInset

        var p = Path()
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
