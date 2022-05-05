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
                 leading: NSLayoutXAxisAnchor?,
                 bottom: NSLayoutYAxisAnchor?,
                 trailing: NSLayoutXAxisAnchor?,
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
        if let left = leading {
            self.leadingAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
        }
        if let right = trailing {
            self.trailingAnchor.constraint(equalTo: right, constant: -padding.right).isActive = true
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
    func centerInSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    @discardableResult
        func addConstraints(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil, centerX: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, centerYConstant: CGFloat = 0, centerXConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
            
            if self.superview == nil {
                return []
            }
            translatesAutoresizingMaskIntoConstraints = false
            
            var constraints = [NSLayoutConstraint]()
            
            if let top = top {
                let constraint = topAnchor.constraint(equalTo: top, constant: topConstant)
                constraint.identifier = "top"
                constraints.append(constraint)
            }
            
            if let left = leading {
                let constraint = leadingAnchor.constraint(equalTo: left, constant: leftConstant)
                constraint.identifier = "left"
                constraints.append(constraint)
            }
            
            if let bottom = bottom {
                let constraint = bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)
                constraint.identifier = "bottom"
                constraints.append(constraint)
            }
            
            if let right = trailing {
                let constraint = trailingAnchor.constraint(equalTo: right, constant: -rightConstant)
                constraint.identifier = "right"
                constraints.append(constraint)
            }

            if let centerY = centerY {
                let constraint = centerYAnchor.constraint(equalTo: centerY, constant: centerYConstant)
                constraint.identifier = "centerY"
                constraints.append(constraint)
            }

            if let centerX = centerX {
                let constraint = centerXAnchor.constraint(equalTo: centerX, constant: centerXConstant)
                constraint.identifier = "centerX"
                constraints.append(constraint)
            }
            
            if widthConstant > 0 {
                let constraint = widthAnchor.constraint(equalToConstant: widthConstant)
                constraint.identifier = "width"
                constraints.append(constraint)
            }
            
            if heightConstant > 0 {
                let constraint = heightAnchor.constraint(equalToConstant: heightConstant)
                constraint.identifier = "height"
                constraints.append(constraint)
            }
            
            NSLayoutConstraint.activate(constraints)
            return constraints
        }

    
}
extension UINavigationController {

    func backgroundColor(_ color: UIColor) {
        navigationBar.setBackgroundImage(nil, for: .default)
//        self.navigationBar.barTintColor = color
//        navigationBar.shadowImage = UIImage()
        if #available(iOS 15, *) {
                // Navigation Bar background color
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = color

//            let titleAttribute = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: color.complement] //alter to fit your needs
//
//            appearance.titleTextAttributes = titleAttribute
                self.navigationBar.standardAppearance = appearance
                self.navigationBar.scrollEdgeAppearance = appearance
                self.navigationBar.compactAppearance = appearance

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

func constraint(equalTo size: CGSize) {
        guard superview != nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
}
