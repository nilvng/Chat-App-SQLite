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
