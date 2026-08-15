import SwiftUI

enum TapePalette {
    static let shell = Color(red: 0.055, green: 0.054, blue: 0.050)
    static let surface = Color(red: 0.092, green: 0.089, blue: 0.082)
    static let inset = Color(red: 0.035, green: 0.034, blue: 0.032)
    static let line = Color.white.opacity(0.10)
    static let text = Color(red: 0.93, green: 0.91, blue: 0.86)
    static let muted = Color.white.opacity(0.48)
    static let accent = Color(red: 0.91, green: 0.69, blue: 0.34)
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
