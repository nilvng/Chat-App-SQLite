//
//  PhotoCollectionViewCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/03/2022.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    var imageView = UIImageView()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()

    }
    
    func configure(with im: UIImage){
        imageView.image = im
    }
    
    func configure(urlString: String){
        guard let url = URL(string: urlString) else {
            print("\(self) Error: invalid image URL")
            return
        }
        imageView.af.setImage(withURL: url)
    }
    
    func setupImageView(){
        contentView.addSubview(imageView)
        imageView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
