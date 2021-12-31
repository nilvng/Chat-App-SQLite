//
//  DefaultAvatarView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/3/21.
//

import UIKit

class AvatarView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(url: String?, text: String?){
        // check if contact has image, or else create an image of their first letter name
        let theKey = url != nil ? url! : text

        guard theKey != nil else {
            print("using hulk avatar")
            self.image = UIImage(named: "default")
            return
        }
        //self.image = UIImage(named: "default") // placeholder avatar
        
        ImageStore.shared.getImage(forUrl: theKey!, type: .rounded){ res in
        if case let .success(image) = res{
                self.image = image
                //print("show avatar")
        } else {
            print("use placeholder avatar...")
            self.usePlaceholderAvatar(with: text!)
            }
        }
    }
    
    func usePlaceholderAvatar(with text: String){
        let firstCharacter = String((text.first)!) as NSString
        let im = self.drawText(text: firstCharacter)
        let config = ImageConfig(url: text, type: .rounded)
        let image = ImageStore.shared.setImage(im, forKey: config, inMemOnly: false)
        self.image = image
    }
    
    func drawText(text: NSString) -> UIImage{
        let size = CGSize(width: 55, height: 55)
        let renderer = UIGraphicsImageRenderer(size: size)
        let colorImage = UIImage(named: "bg_color")!
        let im = renderer.image { _ in
            // text attributes
            let textColor       = UIColor.white
            let textStyle       = NSMutableParagraphStyle()
            textStyle.alignment = NSTextAlignment.center
            let textFont        = UIFont(name: "Helvetica", size: size.width / 3)!
            let attributes      = [NSAttributedString.Key.font:textFont,
                            NSAttributedString.Key.paragraphStyle:textStyle,
                            NSAttributedString.Key.foregroundColor:textColor]
            
            colorImage.draw(in: CGRect(origin: CGPoint.zero, size: size))

            //vertically center (depending on font)
            let text_h      = textFont.lineHeight
            let text_y      = (size.height-text_h)/2
            let text_rect   = CGRect(x: 0, y: text_y, width: size.width, height: text_h)
            text.draw(in: text_rect.integral, withAttributes: attributes)
        }
        return im
    }
    
}
