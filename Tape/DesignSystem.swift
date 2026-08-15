import SwiftUI
import UIKit

enum TapePalette {
    static let deviceTop = Color(red: 0.17, green: 0.17, blue: 0.16)
    static let device = Color(red: 0.105, green: 0.102, blue: 0.095)
    static let deviceBottom = Color(red: 0.060, green: 0.058, blue: 0.054)
    static let button = Color(red: 0.13, green: 0.13, blue: 0.12)
    static let buttonInk = Color(red: 0.045, green: 0.043, blue: 0.040)
    static let window = Color(red: 0.025, green: 0.027, blue: 0.025)
    static let inset = Color(red: 0.032, green: 0.031, blue: 0.029)
    static let text = Color(red: 0.91, green: 0.895, blue: 0.86)
    static let softText = Color(red: 0.72, green: 0.71, blue: 0.67)
    static let windowText = Color(red: 0.81, green: 0.79, blue: 0.74)
    static let muted = Color.white.opacity(0.43)
    static let mutedDot = Color.white.opacity(0.22)
    static let line = Color.white.opacity(0.10)
    static let accent = Color(red: 0.89, green: 0.67, blue: 0.31)
}

struct MonospacedLabel: View {
    let text: String
    let size: CGFloat
    var tracking: CGFloat = 1.4
    var color: Color = TapePalette.muted

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: size, weight: .medium, design: .monospaced))
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

enum Haptics {
    static func transport(_ event: TransportEvent) {
        let generator: UIImpactFeedbackGenerator

        switch event {
        case .play:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .pause:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .skip:
            generator = UIImpactFeedbackGenerator(style: .rigid)
        }

        generator.prepare()
        generator.impactOccurred(intensity: event.intensity)
    }

    static func scrubTick() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func scrubEnd() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.55)
    }

    enum TransportEvent {
        case play, pause, skip

        var intensity: CGFloat {
            switch self {
            case .play: return 0.9
            case .pause: return 0.65
            case .skip: return 0.85
            }
        }
    }
}
