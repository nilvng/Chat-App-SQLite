//
//  AlamoAvatarView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 12/01/2022.
//

import UIKit
import AlamofireImage

class AlamoAvatarView : AvatarView {
    override func update(url: String?, text: String){
        let firstCharacter = String((text.first)!).capitalized as NSString
        
        var placeholder = self.drawText(text: firstCharacter)
        let rad : CGFloat = 20

        placeholder = placeholder.af.imageRounded(withCornerRadius: rad)
        
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: CGSize(width: 60, height: 60),
            radius: rad
        )
        //print("Default avatar...")
        
        if let urlString = url, let urlObj = URL(string: urlString){
            
            //print("fetch image of url: \(urlString)")

            self.af.setImage(withURL: urlObj,
                             placeholderImage: placeholder,
                             filter: filter)
        } else {
            self.image = placeholder
        }
    }
}

