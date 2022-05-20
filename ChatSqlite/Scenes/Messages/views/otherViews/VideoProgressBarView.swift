//
//  videoProgressBarView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/05/2022.
//

import Foundation
import UIKit
import AVKit

protocol VideoProgressBarDelegate : AnyObject{
    func sliderDidChange()
}
class VideoProgressBarView : UIView {
    
    weak var delegate : VideoProgressBarDelegate?
    var slider : UISlider = UISlider()
    var duration : Double?
    var sliderAnimator : UIViewPropertyAnimator?
    var maxSlider : Float = 100
    init(){
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        setupSlider()
    }
    func configure(duration: Double){
        self.duration = duration
        sliderAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: { [weak self] in
            self?.slider.setValue(self!.maxSlider, animated: true)
        }, completion: { _ in
            print("done")
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSlider(){
        self.addSubview(slider)
        slider.minimumValue = 0
        slider.maximumValue = self.maxSlider
        slider.tintColor = .purple
        slider.addConstraints(leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        slider.addTarget(self, action: #selector(timeSliderDidChange), for: [.valueChanged])
    }
    
    func pause(){
        sliderAnimator?.pauseAnimation()
    }
    
    func play(){
        sliderAnimator?.startAnimation()
    }
    
    @objc func timeSliderDidChange(sender: UISlider, event: UIEvent){
        print("Slider: \(event)")
//        playerState = .isSeeking
        sliderAnimator?.pauseAnimation()
        guard let duration = self.duration else {
            return
        }
        let time = Double(sender.value) * duration
//        let newTime = CMTime(seconds: Double(time), preferredTimescale: 600)
//        let tolerBefore = CMTime(seconds: 1.0, preferredTimescale: 600)
//        let tolerAfter = CMTime(seconds: 1.0, preferredTimescale: 600)

//        player?.seek(to: newTime, toleranceBefore: tolerBefore, toleranceAfter: tolerAfter)
        delegate?.sliderDidChange()
        
//        playerState = .doneSeeking
        sliderAnimator?.fractionComplete = time / duration
        sliderAnimator?.startAnimation()
    }
}

extension VideoProgressBarView {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        guard let touch = (touches as NSSet).anyObject() as? UITouch else {
//            return
//        }
//
//        let touchLocation = touch.location(in: self)
//        if slider.layer.presentation()?.hitTest(touchLocation) != nil {
//            print("1") // Do stuff for button
//        }
////        if slider.layer.presentation()?.hitTest(touchLocation) != nil {
////            print("2") // Do stuff
////        }
////        if slider.layer.presentation()?.hitTest(touchLocation) != nil {
////            print(3) // Do stuff
////        }
////        if btnfour.layer.presentation()?.hitTest(touchLocation) != nil {
////            print(4) // Do stuff
////        }
//    }

}
