import UIKit

enum ReferenceArtwork {
    static let image: UIImage = {
        let size = CGSize(width: 1280, height: 960)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { rendererContext in
            let context = rendererContext.cgContext

            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let deviceRect = CGRect(x: 64, y: 72, width: 1152, height: 816)
            let devicePath = UIBezierPath(roundedRect: deviceRect, cornerRadius: 42)
            UIColor(red: 0.07, green: 0.07, blue: 0.065, alpha: 1).setFill()
            devicePath.fill()

            UIColor(red: 0.16, green: 0.16, blue: 0.15, alpha: 1).setStroke()
            devicePath.lineWidth = 4
            devicePath.stroke()

            let windowRect = CGRect(x: 190, y: 195, width: 900, height: 500)
            let windowPath = UIBezierPath(roundedRect: windowRect, cornerRadius: 28)
            UIColor(red: 0.02, green: 0.025, blue: 0.022, alpha: 1).setFill()
            windowPath.fill()

            let leftReel = CGPoint(x: 417, y: 438)
            let rightReel = CGPoint(x: 863, y: 438)
            let reelRadius: CGFloat = 159

            UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1).setFill()
            context.fillEllipse(in: CGRect(
                x: leftReel.x - reelRadius,
                y: leftReel.y - reelRadius,
                width: reelRadius * 2,
                height: reelRadius * 2
            ))

            UIColor(red: 1.0, green: 0.45, blue: 0.02, alpha: 1).setFill()
            context.fillEllipse(in: CGRect(
                x: rightReel.x - reelRadius,
                y: rightReel.y - reelRadius,
                width: reelRadius * 2,
                height: reelRadius * 2
            ))

            drawReelCore(in: context, center: leftReel, radius: 59, tint: UIColor(white: 0.08, alpha: 1))
            drawReelCore(in: context, center: rightReel, radius: 59, tint: UIColor(red: 0.2, green: 0.2, blue: 0.18, alpha: 1))

            let controls: [(CGRect, UIColor)] = [
                (CGRect(x: 250, y: 185, width: 72, height: 58), UIColor(white: 0.18, alpha: 1)),
                (CGRect(x: 355, y: 185, width: 72, height: 58), UIColor(white: 0.18, alpha: 1)),
                (CGRect(x: 826, y: 185, width: 76, height: 60), UIColor(white: 0.18, alpha: 1)),
                (CGRect(x: 910, y: 185, width: 76, height: 60), UIColor(white: 0.18, alpha: 1)),
                (CGRect(x: 995, y: 185, width: 72, height: 60), UIColor(white: 0.18, alpha: 1)),
                (CGRect(x: 860, y: 735, width: 82, height: 74), UIColor(white: 0.18, alpha: 1))
            ]

            for (rect, color) in controls {
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 14)
                color.setFill()
                path.fill()
            }

            UIColor(white: 0.9, alpha: 0.7).setStroke()
            context.setLineWidth(3)

            context.move(to: CGPoint(x: 282, y: 214))
            context.addLine(to: CGPoint(x: 298, y: 205))
            context.addLine(to: CGPoint(x: 298, y: 223))
            context.closePath()
            context.strokePath()

            context.move(to: CGPoint(x: 368, y: 205))
            context.addLine(to: CGPoint(x: 384, y: 214))
            context.addLine(to: CGPoint(x: 368, y: 223))
            context.closePath()
            context.strokePath()

            let play = CGPoint(x: 901, y: 772)
            UIColor(white: 0.9, alpha: 0.72).setFill()
            context.move(to: CGPoint(x: play.x - 10, y: play.y - 16))
            context.addLine(to: CGPoint(x: play.x + 16, y: play.y))
            context.addLine(to: CGPoint(x: play.x - 10, y: play.y + 16))
            context.closePath()
            context.fillPath()
        }
    }

    private static func drawReelCore(
        in context: CGContext,
        center: CGPoint,
        radius: CGFloat,
        tint: UIColor
    ) {
        tint.setFill()
        context.fillEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        UIColor(white: 1, alpha: 0.12).setStroke()
        context.setLineWidth(2)
        context.strokeEllipse(in: CGRect(
            x: center.x - radius + 2,
            y: center.y - radius + 2,
            width: (radius - 2) * 2,
            height: (radius - 2) * 2
        ))

        let spokeOffsets: [CGPoint] = [
            CGPoint(x: 0, y: -0.45),
            CGPoint(x: 0.428, y: -0.139),
            CGPoint(x: 0.265, y: 0.364),
            CGPoint(x: -0.265, y: 0.364),
            CGPoint(x: -0.428, y: -0.139)
        ]

        UIColor(white: 1, alpha: 0.10).setFill()
        for offset in spokeOffsets {
            let spokeCenter = CGPoint(
                x: center.x + offset.x * radius,
                y: center.y + offset.y * radius
            )
            let spokeRect = CGRect(
                x: spokeCenter.x - 4,
                y: spokeCenter.y - radius * 0.12,
                width: 8,
                height: radius * 0.24
            )
            context.saveGState()
            context.translateBy(x: spokeCenter.x, y: spokeCenter.y)
            let angle: CGFloat
            switch offset {
            case CGPoint(x: 0, y: -0.45):
                angle = 0
            case CGPoint(x: 0.428, y: -0.139):
                angle = .pi * 0.4
            case CGPoint(x: 0.265, y: 0.364):
                angle = .pi * 0.8
            case CGPoint(x: -0.265, y: 0.364):
                angle = .pi * 1.2
            default:
                angle = .pi * 1.6
            }
            context.rotate(by: angle)
            context.fill(CGRect(
                x: -spokeRect.width / 2,
                y: -spokeRect.height / 2,
                width: spokeRect.width,
                height: spokeRect.height
            ))
            context.restoreGState()
        }

        UIColor(red: 0.03, green: 0.03, blue: 0.03, alpha: 1).setFill()
        context.fillEllipse(in: CGRect(
            x: center.x - radius * 0.24,
            y: center.y - radius * 0.24,
            width: radius * 0.48,
            height: radius * 0.48
        ))

        UIColor(red: 0.89, green: 0.67, blue: 0.31, alpha: 0.9).setFill()
        let hub: CGFloat = radius * 0.10
        context.fillEllipse(in: CGRect(
            x: center.x - hub,
            y: center.y - hub,
            width: hub * 2,
            height: hub * 2
        ))
    }
}
