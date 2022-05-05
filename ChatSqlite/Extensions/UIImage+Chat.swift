//
//  UIButton+Chat.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

extension UIImage {
    static let bg_yellow_gradient = UIImage(named: "bg-yellow-gradient")
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

extension UIImage {
    func rounded() -> UIImage{
        // create roundedImage from this fullsize image
        let size = CGSize(width: 70, height: 70) // proposed size
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height

        let aspectRatio = max(aspectWidth, aspectHeight)

        let sizeIm = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
        let circleX = aspectWidth > aspectHeight ? 0 :  sizeIm.width/2 - sizeIm.height/2
        let circleY = aspectWidth > aspectHeight ? sizeIm.height/2 - sizeIm.width/2 : 0
        
        let renderer = UIGraphicsImageRenderer(size: sizeIm)
        return renderer.image { _ in
            UIBezierPath(ovalIn: CGRect(x: circleX,
                                                y: circleY,
                                                width: size.width,
                                                height: size.width)).addClip()
            self.draw(in: CGRect(origin: .zero, size: sizeIm))
        }
        
    }
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
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    var averageRGBA : ColorRGB? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        return ColorRGB(red: Int(bitmap[0]), green: Int(bitmap[1]), blue: Int(bitmap[2]), alpha: Int(bitmap[3]))
    }
    
    var averageColorRGBA: (r:Int, g:Int, b:Int, a:Int)? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return (Int(bitmap[0]), Int(bitmap[1]), Int(bitmap[2]), Int(bitmap[3]))
    }
    
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
