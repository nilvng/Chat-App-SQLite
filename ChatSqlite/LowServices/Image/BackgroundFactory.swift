//
//  BubbleImageView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/10/21.
//

import Foundation

//
//  BubbleChatView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/1/21.
//

import UIKit

class BackgroundConfig: NSObject{
    var color : UIColor? = .none
    var corner : UIRectCorner = [.allCorners]
    var radius : CGFloat = 13.0
    
    init(color: UIColor? = .none, corner: UIRectCorner = [.allCorners], radius: CGFloat = 13.0){
        self.color = color
        self.corner = corner
        self.radius = radius
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BackgroundConfig else {
            return false
        }
        return corner == other.corner
        && radius == other.radius
        && color == other.color
    }
    
    override var hash: Int {
        return Int(radius)
    }
    
}

class BackgroundFactory {
    var caches = NSCache<BackgroundConfig, UIImage>()
    
    static var shared = BackgroundFactory()
    
    private init(){};
    
    func getBackground(config: BackgroundConfig) -> UIImage{
        // get background image from cache store
        if let existing = caches.object(forKey: config){
            return existing
        }
                
        // create new background and cache if it hasn't already
        let created =  drawBubble(config: config)
        caches.setObject(created, forKey: config)
        return created
    }
    
    private func drawBubble(config: BackgroundConfig) -> UIImage{
        let edge = 40
        let size = CGSize(width: edge, height: edge)
        let rad = config.radius
        let renderer = UIGraphicsImageRenderer(size: size)
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: .init(origin: .zero, size: size), byRoundingCorners: config.corner, cornerRadii: CGSize(width: rad, height: rad))
            
            config.color?.setFill()
            path.fill()

        }
        let resizable_im = im.resizableImage(withCapInsets: UIEdgeInsets(top: rad,
                                                                         left: rad,
                                                                         bottom: rad,
                                                                         right: rad), resizingMode: .stretch)
        if config.color == .none{
            return resizable_im.withRenderingMode(.alwaysTemplate)

        } else {
            return resizable_im
            }

    }
}
