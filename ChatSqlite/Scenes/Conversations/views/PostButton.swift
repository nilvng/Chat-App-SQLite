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
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowOpacity = 0.5
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
