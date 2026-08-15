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

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backdrop.ignoresSafeArea()
                deck(in: proxy.size)
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden(true)
    }

    private func deck(in screen: CGSize) -> some View {
        let height = min(screen.height * 0.86, 620)
        let width = min(screen.width * 0.92, height * 1.62)

        return ZStack {
            bodyShell(width: width, height: height)

            VStack(spacing: 0) {
                topPlate.frame(height: height * 0.16)
                reelsRow.frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomPlate.frame(height: height * 0.26)
            }
            .frame(width: width, height: height)
            .padding(.horizontal, 12)
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(180))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tape physical music player")
    }

    private func bodyShell(width: CGFloat, height: CGFloat) -> some View {
        let corner = height * 0.06

        return ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(cream)
                .shadow(color: .black.opacity(0.20), radius: 12, y: 8)

            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(ink, lineWidth: 4)

            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(cream)
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(ink, lineWidth: 4)
                }
                .frame(width: width * 0.16, height: 16)
                .offset(x: width * 0.09, y: -height / 2 - 5)

            Rectangle()
                .fill(cream)
                .frame(width: width * 0.16 - 12, height: 10)
                .offset(x: width * 0.09, y: -height / 2)
        }
    }

    private var topPlate: some View {
        HStack(spacing: 16) {
            VStack(spacing: 9) {
                dash(width: 26)
                dash(width: 26)
            }

            HStack(spacing: 14) {
                circleControl(.previous, fill: ink) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 17, weight: .bold))
                }
                circleControl(.rewind, fill: ink) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 17, weight: .bold))
                }
                circleControl(.forward, fill: ink) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 17, weight: .bold))
                }
            }

            Spacer()

            HStack(spacing: 7) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                Text("Memory card")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(ink)

            Spacer()

            HStack(spacing: 14) {
                circleControl(.volumeUp, fill: orange) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                }
                circleControl(.volumeDown, fill: orange) {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .bold))
                }
                circleControl(.eq, fill: orange) {
                    Text("EQ")
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
        .padding(.leading, 26)
        .padding(.trailing, 48)
        .overlay(alignment: .topTrailing) {
            onOff
                .padding(.top, 16)
                .padding(.trailing, 12)
        }
    }

    private var onOff: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up")
                .font(.system(size: 11, weight: .heavy))
            Text("On")
                .font(.system(size: 15, weight: .bold))
                .rotationEffect(.degrees(90))
                .frame(width: 16, height: 26)
            Text("Off")
                .font(.system(size: 15, weight: .bold))
                .rotationEffect(.degrees(90))
                .frame(width: 16, height: 30)
            Image(systemName: "arrow.down")
                .font(.system(size: 11, weight: .heavy))
        }
        .foregroundStyle(ink)
    }

    private func dash(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3.5, style: .continuous)
            .fill(olive)
            .frame(width: width, height: 7)
    }

    private var reelsRow: some View {
        GeometryReader { proxy in
            let d = min(proxy.size.height * 0.80, proxy.size.width * 0.34)

            HStack(spacing: proxy.size.width * 0.10) {
                reelUnit(.left, d: d)
                reelUnit(.right, d: d)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .padding(.horizontal, 34)
        .contentShape(Rectangle())
        .onTapGesture {
            isPlaying.toggle()
            Haptics.transport(isPlaying ? .play : .pause)
        }
    }

    private func reelUnit(_ unit: Side, d: CGFloat) -> some View {
        reel(unit: unit, d: d)
            .frame(width: d, height: d)
            .overlay { toneArm(unit, d: d) }
            .frame(width: d * 1.5, height: d * 1.5)
    }

    private func reel(unit: Side, d: CGFloat) -> some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let degrees = (t * 42).truncatingRemainder(dividingBy: 360)
            let tape = unit == .left ? ink : orange

            ZStack {
                Circle()
                    .fill(tape)
                    .shadow(color: .black.opacity(0.25), radius: 5, x: 3, y: 4)

                Circle().stroke(ink, lineWidth: 3)

                Circle()
                    .fill(hubRing)
                    .frame(width: d * 0.37, height: d * 0.37)
                    .overlay { Circle().stroke(ink, lineWidth: 2) }

                Circle()
                    .fill(.white)
                    .frame(width: d * 0.28, height: d * 0.28)

                ForEach(0..<6, id: \.self) { i in
                    Rectangle()
                        .fill(hubRing)
                        .frame(width: d * 0.05, height: d * 0.08)
                        .offset(y: -d * 0.14)
                        .rotationEffect(.degrees(Double(i) * 60))
                }
            }
            .rotationEffect(.degrees(degrees))
        }
    }

    private func toneArm(_ unit: Side, d: CGFloat) -> some View {
        let mirror: CGFloat = unit == .left ? -1 : 1
        let pivot = CGPoint(x: mirror * -0.42 * d, y: 0.40 * d)
        let elbow = CGPoint(x: mirror * -0.30 * d, y: 0.10 * d)
        let tip = CGPoint(x: mirror * -0.13 * d, y: -0.26 * d)
        let headCenter = CGPoint(x: mirror * -0.10 * d, y: -0.31 * d)
        let armColor = unit == .left ? ink : orange

        return ZStack {
            Path { p in
                p.move(to: pivot)
                p.addLine(to: elbow)
                p.addLine(to: tip)
            }
            .stroke(ink, style: StrokeStyle(lineWidth: d * 0.045, lineCap: .round, lineJoin: .round))

            Path { p in
                p.move(to: pivot)
                p.addLine(to: elbow)
                p.addLine(to: tip)
            }
            .stroke(.white, style: StrokeStyle(lineWidth: d * 0.02, lineCap: .round, lineJoin: .round))

            RoundedRectangle(cornerRadius: d * 0.02)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: d * 0.02)
                        .stroke(ink, lineWidth: 2.5)
                }
                .frame(width: d * 0.09, height: d * 0.16)
                .rotationEffect(.degrees(unit == .left ? 28 : -28))
                .offset(x: headCenter.x, y: headCenter.y)

            ZStack {
                Circle()
                    .fill(armColor)
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 2, y: 3)
                Circle()
                    .stroke(.white, lineWidth: 3)
                    .padding(4)
                Circle()
                    .stroke(ink, lineWidth: 3)
            }
            .frame(width: d * 0.27, height: d * 0.27)
            .offset(x: pivot.x, y: pivot.y)
        }
        .frame(width: d * 1.5, height: d * 1.5)
        .allowsHitTesting(false)
    }

    private var bottomPlate: some View {
        HStack(spacing: 16) {
            Spacer(minLength: 0)

            TrapezoidPanel(topInset: 0.045)
                .fill(cream)
                .overlay {
                    TrapezoidPanel(topInset: 0.045)
                        .stroke(ink, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                }
                .overlay {
                    HStack(spacing: 0) {
                        Circle()
                            .fill(.white)
                            .frame(width: 34, height: 34)
                            .overlay { Circle().stroke(ink, lineWidth: 3) }

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(olive)
                            .overlay { RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(ink, lineWidth: 2.5) }
                            .frame(width: 32, height: 26)
                            .padding(.leading, 44)

                        Spacer()

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(olive)
                            .overlay { RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(ink, lineWidth: 2.5) }
                            .frame(width: 32, height: 26)
                            .padding(.trailing, 44)

                        ZStack {
                            Circle().fill(ink).frame(width: 34, height: 34)
                            Circle().stroke(.white, lineWidth: 5).frame(width: 20, height: 20)
                        }
                    }
                    .padding(.horizontal, 46)
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)

            dash(width: 44)
                .frame(height: 12)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 12)
    }

    private func circleControl(_ control: Control, fill: Color, @ViewBuilder content: () -> some View) -> some View {
        Button {
            trigger(control)
        } label: {
            ZStack {
                Circle().fill(fill).shadow(color: .black.opacity(0.30), radius: 3, x: 2, y: 3)
                Circle().stroke(ink, lineWidth: 2).opacity(fill == orange ? 1 : 0)
                content().foregroundStyle(.white)
            }
            .frame(width: 50, height: 50)
            .scaleEffect(pressedControl == control ? 0.92 : 1)
        }
        .buttonStyle(.plain)
    }

    private func trigger(_ control: Control) {
        pressedControl = control
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            withAnimation(.easeOut(duration: 0.12)) { pressedControl = nil }
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

    private enum Side {
        case left, right
    }
}

struct TrapezoidPanel: Shape {
    var topInset: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * topInset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - rect.width * topInset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
