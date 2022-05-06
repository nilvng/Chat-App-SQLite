//
//  PopAnimator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 05/05/2022.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.8
    var originalFrame = CGRect.zero
    let presenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let toView = transitionContext.view(forKey: .to)!
//        containerView.addSubview(toView)
//        toView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
//        UIView.animate(withDuration: duration,
//                       animations: {
//            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        }, completion: { _ in
//            transitionContext.completeTransition(true)
//        })
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let curView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originalFrame : curView.frame
        let finalFrame = presenting ? curView.frame : originalFrame
        
        let xScaleFactor = presenting ?
        initialFrame.width / finalFrame.width :
        finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
        initialFrame.height / finalFrame.height :
        finalFrame.height / initialFrame.height
        
        // Set the initial position
        let scaledTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            curView.transform = scaledTransform
            curView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            curView.clipsToBounds = true
        }
        
        curView.layer.cornerRadius = presenting ? 20.0 : 0.0
        curView.layer.masksToBounds = true
        
        // Animation
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(curView)
        
        UIView.animate(withDuration: duration, delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       animations: {
            curView.transform = self.presenting ? .identity : scaledTransform // identity is fullsize
            curView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            curView.layer.cornerRadius = !self.presenting ? 20.0 : 0.0
        }, completion: {_ in
            transitionContext.completeTransition(true)
        })
    }
    

}
