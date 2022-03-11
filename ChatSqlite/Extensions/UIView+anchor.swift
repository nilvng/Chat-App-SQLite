//
//  UIViewExtension.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/28/21.
//

import UIKit

extension UIView {
    func addBackground() {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage.bg_yellow_gradient
        self.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            backgroundImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundImageView.widthAnchor.constraint(equalToConstant: self.frame.width + 10),
            backgroundImageView.heightAnchor.constraint(equalToConstant: self.frame.height + 10)
        ])
//        self.sendSubviewToBack(backgroundImageView)

    }
}

extension UIView {
    open func disappearToBottom(withDelay delay: Double = 0.0, withDuration duration: Double = 0.5, offset: CGFloat = 10) {
        self.isHidden = false
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
          // 4
            self.frame.origin.y += offset
        }, completion: { [weak self] _ in
            self?.isHidden = true
        })
    }
    
    open func appearToTop(withDelay delay: Double = 0.0, withDuration duration: Double = 0.5, offset: CGFloat = 10) {

        self.isHidden = false
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
          // 4
            self.frame.origin.y -= offset
        }, completion: nil)
    }
}


extension UIView{
    func rotate(degree: Double, duration: Double = 0.1) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: degree)
        rotation.duration = duration
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    func flash(callback: @escaping () -> Void) {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.1, delay: 0.08, options: [.curveEaseInOut, .autoreverse], animations: {self.alpha = 0.1}, completion: {_ in
            callback()
            self.alpha = 1.0
        })
    }
}



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
