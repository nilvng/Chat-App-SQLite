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
    var progressView: UIProgressView!
    
    var identifier: String!
    
    var targetSize : CGSize  {
    
        return CGSize(width: self.bounds.width, height: self.bounds.height)
        
    }
    
    static let identifier = "PhotoViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
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
    func setupProgressView(){
        progressView = UIProgressView(progressViewStyle: .bar)
        contentView.addSubview(progressView)
        progressView.centerInSuperview()
        progressView.constraint(equalTo: CGSize(width: 50, height: 10))
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
    
    func configure(with asset: PHAsset){
        updateStaticImage(asset: asset)
    }
    
    func configure(id: String, folder: String?=nil, type: ImageFileType){
        identifier = id
        if let myPhotoView = imageView as? PhotoView {
            myPhotoView.load(filename: id, folder: folder, type: type)
        }
    }
    
    func configure(with im: UIImage){
        imageView.image = im
    }
    
    private func updateStaticImage(asset: PHAsset) {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        print("size: \(targetSize)")
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize,
                                                 contentMode: .aspectFill, options: options,
                                              resultHandler: { image, _ in
                                                // PhotoKit finished the request, so hide the progress view.
                                                self.progressView.isHidden = true
                                                
                                                // If the request succeeded, show the image view.
                                                guard let image = image else { return }
                                                
                                                // Show the image.
                                                self.imageView.isHidden = false
                                                self.imageView.image = image
        })
    }
}
