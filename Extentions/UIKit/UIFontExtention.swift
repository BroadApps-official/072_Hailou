import UIKit

extension UIFont {
    struct CustomFont {
        static let largeTitleBold = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let largeTitleRegular = UIFont.systemFont(ofSize: 34)
        static let largeTitleItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 34)
        }()
        
        static let title1Regular = UIFont.systemFont(ofSize: 28)
        static let title1Bold = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title1Italic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 28, weight: .bold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 28)
        }()
        
        static let title2Regular = UIFont.systemFont(ofSize: 22)
        static let title2Bold = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let title2Italic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 22, weight: .bold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 22)
        }()
        
        static let title3Regular = UIFont.systemFont(ofSize: 20)
        static let title3Semibold = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let title3Italic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 20, weight: .bold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 20)
        }()
        
        static let headlineRegular = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let headlineItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 17)
        }()
        
        static let bodyRegular = UIFont.systemFont(ofSize: 17)
        static let bodySemibold = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let bodyItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 17)
        }()    
        
        static let calloutRegular = UIFont.systemFont(ofSize: 16)
        static let calloutSemibol = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        static let subheadlineRegular = UIFont.systemFont(ofSize: 15)
        static let subheadlineSemibold = UIFont.systemFont(ofSize: 15, weight: .semibold)
        static let subheadlineItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 15, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 15)
        }()
        
        static let footnoteRegular = UIFont.systemFont(ofSize: 13)
        static let footnoteSemibold = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        static let caption1Regular = UIFont.systemFont(ofSize: 12)
        static let caption1Medium = UIFont.systemFont(ofSize: 12, weight: .medium)

        static let caption2Regular = UIFont.systemFont(ofSize: 11)
        static let caption2Semibold = UIFont.systemFont(ofSize: 11, weight: .semibold)
    }
}
