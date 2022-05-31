//
//  PopAnimator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 05/05/2022.
//

import UIKit

protocol PopAnimatableViewController {
    func getView() -> UIView
    func getAnimatableView() -> UIView
    func animatableViewRect() -> CGRect
    func getWindow() -> UIWindow?
    func getSourceSnapshot() -> UIView?
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    init?(presenting: Bool,
          firstVC: PopAnimatableViewController,
          secondVC: PopAnimatableViewController) {
        self.presenting = presenting
        self.firstVC = firstVC
        self.secondVC = secondVC
        self.cellSnapshot = firstVC.getSourceSnapshot()
        guard let win = firstVC.getWindow() ?? secondVC.getWindow() else {
            return nil
        }
        self.sourceRect = firstVC.getAnimatableView().convert(firstVC.getAnimatableView().bounds, to: win)
    }
    
    
    let duration = 0.3
    var presenting = true
    
    var firstVC : PopAnimatableViewController
    var secondVC : PopAnimatableViewController
    
    var cellSnapshot : UIView!
    var sourceRect : CGRect
    
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        containerView.addSubview(toView)
        let cellsubSnapshot = firstVC.getAnimatableView()

        guard let window = firstVC.getWindow() ?? secondVC.getWindow(),
              let viewSnapshot = secondVC.getAnimatableView().snapshotView(afterScreenUpdates: true) else {
                  transitionContext.completeTransition(true)
                  return
              }
        sourceRect = firstVC.animatableViewRect() // update cellRect in case new message comes
        print("source: ", sourceRect)
        let backgroundView : UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondVC.getView().backgroundColor
        
        if presenting {
            cellSnapshot = cellsubSnapshot
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 1
        }
        
        [backgroundView, cellSnapshot, viewSnapshot].forEach { containerView.addSubview($0)}
        
        let tosubView = secondVC.getAnimatableView()
        let viewRect = tosubView.convert(tosubView.bounds, to: window)
        let trueImagevViewRect = secondVC.animatableViewRect()
        
        let isPresenting = presenting
        
        // Starting Frame
        viewSnapshot.frame = isPresenting ? self.sourceRect : viewRect
        cellSnapshot.frame = isPresenting ? self.sourceRect : trueImagevViewRect
        viewSnapshot.alpha = isPresenting ? 0 : 1
        cellSnapshot.alpha = isPresenting ? 1 : 0
        toView.alpha = 0
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1){
                // Ending Frame
                viewSnapshot.frame = isPresenting ? viewRect :self.sourceRect
                self.cellSnapshot.frame = isPresenting ? trueImagevViewRect : self.sourceRect
                toView.alpha = 1
            }
                // Gradually replace cellView with fullView
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6){
                self.cellSnapshot.alpha = isPresenting ? 1 : 1
                viewSnapshot.alpha = isPresenting ? 1 : 0
            }
            // Gradually Show the background color of MediaView
            if isPresenting {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3){
                fadeView.alpha = 1
                }
            } else {
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 1){
                    fadeView.alpha = 0
                    }
            }
            
            
        }, completion: { _ in
            self.cellSnapshot.removeFromSuperview()
            viewSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
        
    }

}
