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
    func didSelect(i: Int, of message: MessageDomain)
    
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
        print("Init Grid Cell")
        setupCollectionView()
        layoutCollectionView()
        contentView.clipsToBounds = true
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = false
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
        messageContainerView.widthAnchor.constraint(equalToConstant: 220).isActive = true
        collectionView.addConstraints(top: messageContainerView.topAnchor,
                                      bottom: messageContainerView.bottomAnchor,
                                      trailing: messageContainerView.trailingAnchor,
                                      widthConstant: 220)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

// MARK: - Configure
    override func configure(with: MessageDomain, indexPath: IndexPath, isStartMessage: Bool, isEndMessage: Bool){
        super.configure(with: with, indexPath: indexPath, isStartMessage: isStartMessage, isEndMessage: isEndMessage)
//        setupCollectionView()
    }

    
    func configure(){
        images = [UIImage(named: "green-yellow"), UIImage(named: "dream-hike"), UIImage(named: "purple-blue"), UIImage(named: "dream-lab")]
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            self.collectionView.layoutIfNeeded()
            self.layoutIfNeeded()
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            let padding = bubbleVPadding + BubbleConstant.contentVPadding * 2
            return CGSize(width: contentSize.width, height: contentSize.height + padding)
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
//        collectionView.reloadData()
    }
}

// MARK: CollageLayout Delegate
extension ImageGridCell : CollageLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, ratioHWForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let prep = message.getPrep(index: indexPath.item) else {
            fatalError("No Image Prep but show a ImageGridCell??")
        }
        return CGFloat(prep.height) / CGFloat(prep.width)
    }
    
    
}

// MARK: - CollectionView DataSource
extension ImageGridCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        message.mediaPreps?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridViewCell.identifier, for: indexPath) as! PhotoGridViewCell
        let i = indexPath.item
        cell.identifier = message.getPrep(index: i)?.imageID
        Task{ [weak self] in
            do{
                let im = try await LocalMediaWorker.shared.getImage(index: i,
                                                                of: message,
                                                                type: .thumbnail)
                if cell.identifier == message.getPrep(index: i)?.imageID{
                    cell.configure(with: im)
                }
            } catch {
                print("\(self): Failed loading image from local storage")
            }
        }
        return cell
    }
}

extension ImageGridCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gridCellDelegate?.didSelect(i: indexPath.item, of: message)
    }
}
