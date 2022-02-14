//
//  UIViewExtension.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/28/21.
//

import UIKit

extension UIView {
    
    func anchor (top: NSLayoutYAxisAnchor?,
                 left: NSLayoutXAxisAnchor?,
                 bottom: NSLayoutYAxisAnchor?,
                 right: NSLayoutXAxisAnchor?,
                 padding: UIEdgeInsets = .zero,
                 size: CGSize = .zero,
                 enableInsets: Bool=false) {
        var topInset = CGFloat(0)
        var bottomInset = CGFloat(0)
        
        translatesAutoresizingMaskIntoConstraints = false
       
        if #available(iOS 11, *), enableInsets {
            let insets = self.safeAreaInsets
            topInset = insets.top
            bottomInset = insets.bottom
            
            print("Top: \(topInset)")
            print("bottom: \(bottomInset)")
        }
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top+topInset).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -padding.right).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom-bottomInset).isActive = true
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
    }
    
}
extension UIView {

  func fadeIn(duration: TimeInterval = 0.5,
              delay: TimeInterval = 0.0,
              completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
    UIView.animate(withDuration: duration,
                   delay: delay,
                   options: UIView.AnimationOptions.curveEaseOut,
                   animations: {
      self.alpha = 1.0
    }, completion: completion)
  }

  func fadeOut(duration: TimeInterval = 0.5,
               delay: TimeInterval = 0.0,
               completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
    UIView.animate(withDuration: duration,
                   delay: delay,
                   options: UIView.AnimationOptions.curveEaseOut,
                   animations: {
      self.alpha = 0.0
    }, completion: completion)
  }
}
