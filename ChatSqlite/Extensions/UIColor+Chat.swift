//
//  UIColor+Chat.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/27/21.
//

import UIKit

extension UIColor {
    static let zaloBlue = UIColor(named: "ZaloBlue")
    static let complementZaloBlue = UIColor(named: "ComplementZaloBlue")
    static let trueLightGray = UIColor(named: "trueLightGray")
    static let trueLightGray2 = UIColor(named: "trueLightGray2")
    static let babyBlue = UIColor(named: "babyBlue")

}
extension UIColor {

    var complement: UIColor {
        return self.withHueOffset(0.5)
    }
    
    var splitComplement1: UIColor {
        return self.withHueOffset(210 / 360)
    }
    var triadic0: UIColor {
        return self.withHueOffset(120 / 360)
    }
    func withHueOffset(_ offset: CGFloat) -> UIColor {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return UIColor(hue: fmod(h + offset, 1), saturation: s, brightness: b, alpha: a)
        }
}
extension UIColor {

    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
extension UIColor {
    /// color components value between 0 to 255
      public convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
      }
}


extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor{
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    func darker(amount : CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(amount: 1 - amount)
      }
    private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
            var hue         : CGFloat = 0
            var saturation  : CGFloat = 0
            var brightness  : CGFloat = 0
            var alpha       : CGFloat = 0

            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return UIColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }

    }
}
