import UIKit

enum ReferenceArtwork {
    static let image: UIImage = {
        let size = CGSize(width: 1280, height: 960)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            UIColor.black.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

            let deviceRect = CGRect(x: 64, y: 72, width: 1152, height: 816)
            UIColor(red: 0.07, green: 0.07, blue: 0.065, alpha: 1).setFill()
            UIBezierPath(roundedRect: deviceRect, cornerRadius: 42).fill()

            UIColor(red: 0.16, green: 0.16, blue: 0.15, alpha: 1).setStroke()
            let border = UIBezierPath(roundedRect: deviceRect, cornerRadius: 42)
            border.lineWidth = 4
            border.stroke()

            let windowRect = CGRect(x: 190, y: 195, width: 900, height: 500)
            UIColor(red: 0.02, green: 0.025, blue: 0.022, alpha: 1).setFill()
            UIBezierPath(roundedRect: windowRect, cornerRadius: 28).fill()

            drawReel(center: CGPoint(x: 417, y: 438), radius: 159, color: UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1))
            drawReel(center: CGPoint(x: 863, y: 438), radius: 159, color: UIColor(red: 1, green: 0.45, blue: 0.02, alpha: 1))

            let controls = [
                CGRect(x: 250, y: 185, width: 72, height: 58),
                CGRect(x: 355, y: 185, width: 72, height: 58),
                CGRect(x: 826, y: 185, width: 76, height: 60),
                CGRect(x: 910, y: 185, width: 76, height: 60),
                CGRect(x: 995, y: 185, width: 72, height: 60),
                CGRect(x: 860, y: 735, width: 82, height: 74)
            ]

            UIColor(white: 0.18, alpha: 1).setFill()
            for rect in controls {
                UIBezierPath(roundedRect: rect, cornerRadius: 14).fill()
            }

            UIColor(white: 0.9, alpha: 0.72).setFill()
            let playRect = CGRect(x: 891, y: 756, width: 20, height: 32)
            let playPath = UIBezierPath()
            playPath.move(to: CGPoint(x: playRect.minX, y: playRect.minY))
            playPath.addLine(to: CGPoint(x: playRect.maxX, y: playRect.midY))
            playPath.addLine(to: CGPoint(x: playRect.minX, y: playRect.maxY))
            playPath.close()
            playPath.fill()
        }
    }

    private static func drawReel(center: CGPoint, radius: CGFloat, color: UIColor) {
        color.setFill()
        UIBezierPath(ovalIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )).fill()

        UIColor(white: 1, alpha: 0.12).setStroke()
        let outer = UIBezierPath(ovalIn: CGRect(
            x: center.x - radius + 2,
            y: center.y - radius + 2,
            width: (radius - 2) * 2,
            height: (radius - 2) * 2
        ))
        outer.lineWidth = 2
        outer.stroke()

        UIColor(white: 1, alpha: 0.10).setFill()
        let spokeWidth = radius * 0.05
        let spokeHeight = radius * 0.34
        let spokeX = center.x - spokeWidth / 2
        let spokeY = center.y - radius * 0.47

        for index in 0..<5 {
            let spoke = UIBezierPath(
                roundedRect: CGRect(x: spokeX, y: spokeY, width: spokeWidth, height: spokeHeight),
                cornerRadius: spokeWidth / 2
            )
            spoke.apply(CGAffineTransform(rotationAngle: CGFloat(index) * 0.4))
            spoke.apply(CGAffineTransform(translationX: center.x - center.x, y: 0))
            spoke.fill()
        }

        UIColor(red: 0.03, green: 0.03, blue: 0.03, alpha: 1).setFill()
        UIBezierPath(ovalIn: CGRect(
            x: center.x - radius * 0.24,
            y: center.y - radius * 0.24,
            width: radius * 0.48,
            height: radius * 0.48
        )).fill()

        UIColor(red: 0.89, green: 0.67, blue: 0.31, alpha: 0.9).setFill()
        let hub = radius * 0.10
        UIBezierPath(ovalIn: CGRect(
            x: center.x - hub,
            y: center.y - hub,
            width: hub * 2,
            height: hub * 2
        )).fill()
    }
}
