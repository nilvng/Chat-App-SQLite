//
//  Theme.swift
//  Chat App
//
//  Created by Nil Nguyen on 11/7/21.
//

import UIKit

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

extension Theme {
    static let basic = Theme(colors: [CGColor(red: 34/255, green: 148/255, blue: 251/255, alpha: 1),
                                      CGColor(red: 150/255, green: 34/255, blue: 251/255, alpha: 1)], accent: UIColor.blue)

    static let earthy = Theme(colors: [CGColor(red: 253/255, green: 187/255, blue: 45/255, alpha: 1),
                                       CGColor(red: 34/255, green: 193/255, blue: 195/255, alpha: 1)], accent: UIColor.green,
                                 background: UIImage(named: "earthyBg"))
    static let sunset = Theme(colors: [CGColor(red: 131/255, green: 58/255, blue: 180/255, alpha: 1),
                                       CGColor(red: 252/255, green: 176/255, blue: 69/255, alpha: 1)], accent: .orange, background: UIImage(named: "sunsetBg"))
}

extension UIImage {
      func getPixelColor(pos: CGPoint) -> UIColor? {
        
        guard let cgImage = self.cgImage,
              let pixelData = cgImage.dataProvider?.data,
              let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData) else {
            print("Problem in getting gradient image")
            return nil
        }
        
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent

        let pixelInfo : Int = Int(pos.y) * bytesPerRow + Int(pos.x) * bytesPerPixel
        
        
        if (pixelInfo < 0){
            return .black
        }
          let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
          let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
          let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
          let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

          return UIColor(red: b, green: g, blue: r, alpha: a)
      }
  }

extension UIImage {
    static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
