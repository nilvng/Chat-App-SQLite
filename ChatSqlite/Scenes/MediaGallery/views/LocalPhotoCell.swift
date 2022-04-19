//
//  LocalPhotoCell.swift
//  PinterestView
//
//  Created by LAP11353 on 28/03/2022.
//

import UIKit
import Photos
class LocalPhotoCell : UICollectionViewCell {
    let imageView = UIImageView()
    let textLabel = UILabel()
    let spinnerView = UIActivityIndicatorView()
    let durationLabel = UILabel()
    
    var livePhotoBadgeImage: UIImage! {
        didSet {
//            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    var representedAssetIdentifier: String!
    
    static let identifier = "LocalPhotoViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
        setupImageView()
        setupTextLabel()
        setupDurationLabel()
    }
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProgressView(){
        contentView.addSubview(spinnerView)
        spinnerView.centerInSuperview()
    }
    func setupDurationLabel(){
        durationLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(durationLabel)
        durationLabel.addConstraints(bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, bottomConstant: 3, rightConstant: 3)
    }
    
    func setupTextLabel(){
        contentView.addSubview(textLabel)
        textLabel.centerInSuperview()
        textLabel.textColor = .yellow
        textLabel.isHidden = true
            
    }
    var isAlreadySelected : Bool {
        get{
            return !textLabel.isHidden
        }
    }
    
    func select(number: Int){
        textLabel.isHidden = false
        textLabel.text = "\(number)"
        textLabel.sizeToFit()
    }
    func unselect(){
        textLabel.text = ""
        textLabel.isHidden = true
    }
    
    func setupImageView(){
        contentView.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.addConstraints(top: contentView.topAnchor,
                                 leading: contentView.leadingAnchor,
                                 bottom: contentView.bottomAnchor,
                                 trailing: contentView.trailingAnchor)
        
    }
    
    func startLoading(){
        spinnerView.startAnimating()
    }
    func stopLoading(){
        spinnerView.stopAnimating()
    }
    
    func configure(name: String){
        imageView.image = UIImage(named: name)
    }
    func configure(with image: UIImage?, videoDuration: Int?){
        imageView.image = image
        if let dur = videoDuration {
            durationLabel.isHidden = false
            let formatted = formatDuration(secs: dur)
            durationLabel.text = formatted
            print(formatted)
        } else {
            durationLabel.isHidden = true
        }

    }
    
    func formatDuration (secs: Int) -> String{
        let min = secs / 60
        
        return "\(min):\(secs % 60)"
    }

    
}
