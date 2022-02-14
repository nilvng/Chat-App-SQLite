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

extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor{
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
