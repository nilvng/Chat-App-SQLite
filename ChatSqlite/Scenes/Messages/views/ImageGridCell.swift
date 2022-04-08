//
//  ImageGridCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/03/2022.
//

import UIKit

class ImageGridCell: UITableViewCell {
    static let ID = "ImageGridCell"
    var collectionView : UICollectionView?
    var photoItems : [UIImage] = []
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutCollectionView()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    func configure(with model: MessageDomain, indexPath: IndexPath, isStartMessage isStart: Bool, isEndMessage isEnd: Bool) {
//        super.configure(with: model, indexPath: indexPath, isStartMessage: isStart, isEndMessage: isEnd)
//        layoutCollectionView()
//        setupCollectionView()
        photoItems = model.images
        collectionView?.reloadData()
        
    }
    
    func layoutCollectionView(){
        let v = UICollectionView(frame: .zero,
                                 collectionViewLayout: UICollectionViewFlowLayout())
        collectionView = v
        contentView.addSubview(collectionView!)
        collectionView!.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor,
                                      bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }
    
    func setupCollectionView(){
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView?.collectionViewLayout = layout
    }
    
    override func prepareForReuse(){
        collectionView = nil
    }

}

extension ImageGridCell : PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, ratioHWForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let item = photoItems[indexPath.row]
        let width = item.size.width
        let height = item.size.height
        return height / width
    }
    
    
}

extension ImageGridCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoItems.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath) as? PhotoCollectionCell  else {
        fatalError()

        }
        cell.configure(with: photoItems[indexPath.row])
        return cell
    }
}

extension ImageGridCell : UICollectionViewDelegate{
    
}


