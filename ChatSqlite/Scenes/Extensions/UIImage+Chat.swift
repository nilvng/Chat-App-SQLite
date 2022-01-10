//
//  UIButton+Chat.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

extension UIImage {
    static let btn_send_forboy = UIImage(named: "btn_send_forboy")?.withRenderingMode(.alwaysTemplate)
    static let btn_send_forboy_disabled = UIImage(named: "btn_send_forboy_disable")?.withRenderingMode(.alwaysTemplate)
    static let chat_menu = UIImage(named: "icHeaderList")
    static let back_button = UIImage(named: "icn_navigation_button_back_white")

    static let navigation_search = UIImage(named: "icn_navigation_button_search")
    static let navigation_search_selected = UIImage(named: "icn_navigation_button_search_selected")
    
    static let navigation_button_plus = UIImage(named: "navigation_button_plus")
    static let navigation_button_plus_selected = UIImage(named: "navigation_button_plus_selected")
    
    static let compose_message = UIImage(named: "compose_message")
    static let new_contact = UIImage(named: "NewContact")
    static let new_group_chat = UIImage(named: "NewGroupChat")

}

extension UIImage{
    func resizedImage(size: CGSize) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

    }
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
