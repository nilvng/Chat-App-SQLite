//
//  ImageGridCell.swift
//  PinterestView
//
//  Created by LAP11353 on 31/03/2022.
//

import Foundation
import UIKit
import Photos
import PhotosUI

protocol GridCellDelegate : AnyObject {
    func didSelect(asset: PHAsset)
}

class ImageGridCell : MessageCell {
    
    static let ID = "ImageGridCell"
    
//    var model : MessageDomain!
    var images: [UIImage?] = []
    var collectionView : UICollectionView!
    var collectionViewHeightConstraint : NSLayoutConstraint?
    var numberOfItemsInRow = 3
    var cellPadding : CGFloat = 3
    weak var gridCellDelegate : GridCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
        layoutCollectionView()
//        contentView.backgroundColor = UIColor(r: 82, g: 120, b: 72)
//        collectionView.clipsToBounds = true
    }
    
    func setupCollectionView(){
        let layout = CollageLayout()
        layout.delegate = self
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoGridViewCell.self, forCellWithReuseIdentifier: PhotoGridViewCell.identifier)
    }
    
    func layoutCollectionView(){
        messageContainerView.addSubview(collectionView)
        collectionView.addConstraints(top: messageContainerView.topAnchor,
                                      bottom: messageContainerView.bottomAnchor,
                                      trailing: messageContainerView.trailingAnchor,
                                      widthConstant: 210)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ model : MessageDomain){
//        self.model = model
        
    }
    override func configure(with: MessageDomain, indexPath: IndexPath, isStartMessage: Bool, isEndMessage: Bool){
        super.configure(with: with, indexPath: indexPath, isStartMessage: isStartMessage, isEndMessage: isEndMessage)
    }

    
    func configure(){
        images = [UIImage(named: "green-yellow"), UIImage(named: "dream-hike"), UIImage(named: "purple-blue"), UIImage(named: "dream-lab")]
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            self.collectionView.layoutIfNeeded()
            self.layoutIfNeeded()
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            return CGSize(width: contentSize.width, height: contentSize.height)
        }
}

extension ImageGridCell : CollageLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, ratioHWForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let a = message.getAsset(index: indexPath.row) else {
            return 1
        }
        return CGFloat(a.pixelHeight) / CGFloat(a.pixelWidth)
        
    }
    
    
}

extension ImageGridCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        message.urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridViewCell.identifier, for: indexPath) as! PhotoGridViewCell
        
        Task{
            do{
                let im = try await LocalMediaWorker.shared.getImage(index: indexPath.item,
                                                                of: message,
                                                                type: .thumbnail)
                cell.configure(with: im)
            } catch {
                print("\(self): Failed loading image from local storage")
            }
        }
        return cell
    }
}

extension ImageGridCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let a = message.getAsset(index: indexPath.row) else {
            fatalError()
        }
        gridCellDelegate?.didSelect(asset: a)
    }
}
