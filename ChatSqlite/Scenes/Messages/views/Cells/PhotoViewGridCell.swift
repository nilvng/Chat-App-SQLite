//
//  PhotoCollectionViewCell.swift
//  PinterestView
//
//  Created by LAP11353 on 28/03/2022.
//

import UIKit
import Photos
import PhotosUI
import CloudKit

class PhotoViewGridCell: UICollectionViewCell {
    let imageView : UIImageView = PhotoView()
    let textLabel = UILabel()
    
    var identifier: String!
    
    var targetSize : CGSize  {
    
        return CGSize(width: self.bounds.width, height: self.bounds.height)
        
    }
    
    static let identifier = "PhotoViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
//        setupTextLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextLabel(){
        contentView.addSubview(textLabel)
        textLabel.centerInSuperview()
        
    }
    
    func setupImageView(){
        contentView.addSubview(imageView)
        imageView.addConstraints(top: contentView.topAnchor,
                                 leading: contentView.leadingAnchor,
                                 bottom: contentView.bottomAnchor,
                                 trailing: contentView.trailingAnchor)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true


    }
    
    func configure(name: String){
        imageView.image = UIImage(named: name)

    }
    
    func configure(id: String, folder: String?=nil, backgroundColor: UIColor? = .trueLightGray){
        identifier = id
        if let myPhotoView = imageView as? PhotoView {
            myPhotoView.load(filename: id, folder: folder, type: .thumbnail, backgroundColor: backgroundColor)
        }
    }
    
    
    func configure(with im: UIImage){
        imageView.image = im
    }
}
