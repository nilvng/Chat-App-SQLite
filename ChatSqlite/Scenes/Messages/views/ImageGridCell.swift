//
//  ImageGridCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/03/2022.
//

import UIKit

class ImageGridCell: UITableViewCell {
    
    enum Section {
        case main
    }
    
    var collectionView : UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// --MARK: CollectionView
extension ImageGridCell {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        let spacing = CGFloat(2)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing

        // Another way to add spacing. This is done for the section.
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    func configureHierarchy() {
        collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.identifier)
        contentView.addSubview(collectionView)
    }
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCollectionCell.identifier,
                for: indexPath) as? ImageCollectionCell else { fatalError("Cannot create new cell") }

            // Populate the cell with our item description.
            
            // Return the cell.
            return cell
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<94))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

class ImageCollectionCell : UICollectionViewCell {
    static let identifier = "ImageCell"
}
