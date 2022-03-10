//
//  PostButton.swift
//  ChatSqlite
//
//  Created by LAP11353 on 08/03/2022.
//

import Foundation
import UIKit

class PostButton : UIButton {
    var mainImage : UIImage?
    var secondImage : UIImage?
    init(){
        super.init(frame: .zero)
        self.sizeToFit()
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 3)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        let im = image?.af.imageRoundedIntoCircle()
        super.setBackgroundImage(im, for: state)

    }
}
