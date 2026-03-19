import SwiftUI
import UIKit

struct AppColors {
    static let white = Color.white
    static let black = Color.black
    
    static let neutral950 = Color(#colorLiteral(red: 0.07711998373, green: 0.08371577412, blue: 0.09550275654, alpha: 1))
    static let neutral900 = Color(#colorLiteral(red: 0.1058823529, green: 0.1058823529, blue: 0.1176470588, alpha: 1))
    static let neutral800 = Color(#colorLiteral(red: 0.2465126216, green: 0.2469652295, blue: 0.2605620325, alpha: 1))
    static let neutral700 = Color(#colorLiteral(red: 0.3451192081, green: 0.3455281854, blue: 0.3579348922, alpha: 1))
    static let neutral500 = Color(#colorLiteral(red: 0.3451192081, green: 0.3455281854, blue: 0.3579348922, alpha: 1))
    static let neutral400 = Color(#colorLiteral(red: 0.568627451, green: 0.5647058824, blue: 0.5764705882, alpha: 1))
    static let neutral300 = Color(#colorLiteral(red: 0.6745098039, green: 0.6705882353, blue: 0.6823529412, alpha: 1))
    static let neutral200 = Color(#colorLiteral(red: 0.7803921569, green: 0.7764705882, blue: 0.7882352941, alpha: 1))
    
    static let state100 = Color(#colorLiteral(red: 0.8823529412, green: 0.8862745098, blue: 0.9176470588, alpha: 1))
    static let state200 = Color(#colorLiteral(red: 0.7725490196, green: 0.7764705882, blue: 0.8078431373, alpha: 1))
    static let state800 = Color(#colorLiteral(red: 0.1803921569, green: 0.1882352941, blue: 0.2156862745, alpha: 1))
    
    static let primary = Color(#colorLiteral(red: 0.8196078431, green: 0.737254902, blue: 0.9960784314, alpha: 1))
    static let primary800 = Color(#colorLiteral(red: 0.2809826732, green: 0.2134181261, blue: 0.4445728958, alpha: 1))
    static let primary750 = Color(#colorLiteral(red: 0.2588235294, green: 0.1921568627, blue: 0.4156862745, alpha: 1))
    
    static let green = Color.green
    
    static let yellow200 = Color(#colorLiteral(red: 0.9960784314, green: 0.9411764706, blue: 0.5411764706, alpha: 1))
    static let yellow800 = Color(#colorLiteral(red: 0.5215686275, green: 0.3019607843, blue: 0.05490196078, alpha: 1))
    
    static let green200 = Color(#colorLiteral(red: 0.7333333333, green: 0.968627451, blue: 0.8156862745, alpha: 1))
    static let green800 = Color(#colorLiteral(red: 0.0862745098, green: 0.3960784314, blue: 0.2039215686, alpha: 1))
    
    static let info200 = Color(#colorLiteral(red: 0.7294117647, green: 0.9019607843, blue: 0.9921568627, alpha: 1))
    static let info800 = Color(#colorLiteral(red: 0.02745098039, green: 0.3490196078, blue: 0.5215686275, alpha: 1))
    
    static let red800 = Color(#colorLiteral(red: 0.6, green: 0.1058823529, blue: 0.1058823529, alpha: 1))
    static let red400 = Color(#colorLiteral(red: 0.9725490196, green: 0.4431372549, blue: 0.4431372549, alpha: 1))
    static let red200 = Color(#colorLiteral(red: 0.9960784314, green: 0.7921568627, blue: 0.7921568627, alpha: 1))
}

extension UIApplication {
    static var safeScreenSize: CGSize {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            ?? scenes.first as? UIWindowScene
        
        return windowScene?.screen.bounds.size ?? CGSize(width: 390, height: 844)
    }
}

struct Responsive {
    private static let baseWidth: CGFloat = 402.0
    private static let baseHeight: CGFloat = 874.0
    
    static func width(_ value: CGFloat) -> CGFloat {
        let screenWidth = UIApplication.safeScreenSize.width
        return (value / baseWidth) * screenWidth
    }
    
    static func height(_ value: CGFloat) -> CGFloat {
        let screenHeight = UIApplication.safeScreenSize.height
        return (value / baseHeight) * screenHeight
    }
    
    static func fontSize(_ size: CGFloat) -> CGFloat {
        let screenWidth = UIApplication.safeScreenSize.width
        let ratio = screenWidth / baseWidth
        
        let scaledSize = size * ratio
        return max(scaledSize, size * 0.8)
    }
    
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: fontSize(size), weight: weight)
    }
}
