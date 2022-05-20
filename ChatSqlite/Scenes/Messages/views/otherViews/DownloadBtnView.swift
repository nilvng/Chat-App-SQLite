//
//  DownloadBtnView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/01/2022.
//

import Foundation
import UIKit
import Alamofire

protocol DownloadBtnDelegate{
    func start()
}

class DownloadBtnView : UIView {
    lazy var progressCircleLayer : CAShapeLayer  = {
        let layer = CAShapeLayer()
    
        let circlepath = UIBezierPath(arcCenter: self.center, radius: 10,
                                      startAngle: 0, endAngle: CGFloat.pi * 2,
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
    
    var delegate : DownloadBtnDelegate?

    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        self.setupButton()
        self.setupCircle()
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
        
        guard progressCircleLayer.strokeEnd == 0 else {
            print("DownloadBtn: already active...")
            return
        }

        delegate?.start()
        
        
    }
    
    func progressTo(val : Double){
        progressCircleLayer.strokeEnd = val
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
