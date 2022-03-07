//
//  Theme.swift
//  Chat App
//
//  Created by Nil Nguyen on 11/7/21.
//

import UIKit


enum ThemeOptions : Int, Codable{
    case basic
    case earthy
    case sunset
    
    func getTheme() -> Theme{
        switch self {
        case .basic:
            return Theme.basic
        case .earthy:
            return Theme.earthy
        case .sunset:
            return Theme.sunset

        }
    }
    
    static func fromTheme(_ theme : Theme) -> ThemeOptions {
        switch theme {
        case Theme.basic :
            return .basic
        case Theme.earthy:
            return .earthy
        case Theme.sunset:
            return .sunset
        default:
            return basic
        }
    }
}

struct Theme{
    var accentColor : UIColor
    var gradientImage : UIImage
    var backgroundImage : UIImage?
    
    init(colors: [CGColor], accent: UIColor, background: UIImage? = nil) {
        let width =  UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        gradientImage = UIImage.gradientImageWithBounds(bounds: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)),
                                                        colors: colors)
        self.backgroundImage = background
        self.accentColor = accent
    }
}

extension Theme : Equatable{
    static let basic = Theme(colors: [CGColor(red: 34/255, green: 148/255, blue: 251/255, alpha: 1),
                                      CGColor(red: 150/255, green: 34/255, blue: 251/255, alpha: 1)], accent: UIColor.blue)

    static let earthy = Theme(colors: [CGColor(red: 253/255, green: 187/255, blue: 45/255, alpha: 1),
                                       CGColor(red: 34/255, green: 193/255, blue: 195/255, alpha: 1)], accent: UIColor.green,
                                 background: UIImage(named: "earthyBg"))
    static let sunset = Theme(colors: [CGColor(red: 200/255, green: 45/255, blue: 219/255, alpha: 1),
                                       CGColor(red: 253/255, green: 147/255, blue: 6/255, alpha: 1)], accent: .orange, background: UIImage(named: "sunsetBg"))
}


