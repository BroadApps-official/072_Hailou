import UIKit

class GradientLabel: UILabel {
    var gradientColors: [CGColor] = [
        UIColor(red: 249/255, green: 171/255, blue: 251/255, alpha: 1).cgColor,
        UIColor(red: 151/255, green: 208/255, blue: 248/255, alpha: 1).cgColor
    ]

    override func drawText(in rect: CGRect) {
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }

    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint(x: 0, y: 0),
                                    end: CGPoint(x: size.width, y: 0), 
                                    options: [])

        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
}
