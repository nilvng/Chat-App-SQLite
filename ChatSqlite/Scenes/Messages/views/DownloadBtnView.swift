//
//  DownloadBtnView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/01/2022.
//

import Foundation
import UIKit
import Alamofire

class DownloadBtnView : UIView {
    lazy var progressCircleLayer : CAShapeLayer  = {
        let layer = CAShapeLayer()
        print(self.center)
    
        let circlepath = UIBezierPath(arcCenter: self.center, radius: 10,
                                      startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2,
                                      clockwise: true)
        
        layer.path = circlepath.cgPath
        layer.lineWidth = 1
        layer.lineCap = .round
        layer.strokeEnd = 0
        layer.strokeColor = UIColor.zaloBlue?.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        return layer
        
    }()
    lazy var downloadButton : UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .light, scale: .large)

        button.setImage(UIImage(systemName: "arrow.down",withConfiguration: largeConfig), for: .normal)
        button.setImage(UIImage(systemName: "arrow.down.fill", withConfiguration: largeConfig), for: .highlighted)

        return button
    }()
    
    var url : String?

    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        self.setupButton()
        self.setupCircle()
    }
    
    func setURL(_ url : String){
        self.url = url
    }
    
    func setupCircle(){
        self.layer.addSublayer(progressCircleLayer)
    }
    func setupButton(){
        self.addSubview(downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            downloadButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            downloadButton.topAnchor.constraint(equalTo: topAnchor),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    @objc func buttonPressed(){
        print("downloading...")
        
        guard let u = url else {
            return
        }
        
        AF.download(u)
            .downloadProgress { progress in
                let val = progress.fractionCompleted
                print("Downloading: ... \(val * 100)%")
                DispatchQueue.main.async {
                    self.progressTo(val: val)
                }
                
            }
            .responseURL { file in
            print("download file to: \(file)")

        }
        
    }
    
    func progressTo(val : Double){
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = val
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        
        progressCircleLayer.add(basicAnimation, forKey: "download")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
