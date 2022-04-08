//
//  PinterestLayout.swift
//  ChatSqlite
//
//  Created by LAP11353 on 29/03/2022.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(
      _ collectionView: UICollectionView,
      ratioHWForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
  // 1 to ask for the height of the image
  weak var delegate: PinterestLayoutDelegate?

  // 2 necessary variables to layout collection view
  private let numberOfColumns = 2
  private let cellPadding: CGFloat = 2

  // 3 caches cell layout attributes
  private var cache: [UICollectionViewLayoutAttributes] = []

  // 4 variables to be calculated
  private var contentHeight: CGFloat = 0

  // actual content width = width - inset
  private var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }

  // 5 collection size
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  // Calculate size for every cells
  override func prepare() {
    // 1
    guard
      cache.isEmpty,
      let collectionView = collectionView
      else {
        return
    }
    // 2 estimate the offset X and initial offset Y for column a.
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset: [CGFloat] = []
    for column in 0..<numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth)
    }
    var column = 0
    var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
      
    // 3 go through every item
    for item in 0..<collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: item, section: 0)
        
      // 4 calculate height
      let ratio = delegate?.collectionView(
        collectionView,
        ratioHWForPhotoAtIndexPath: indexPath) ?? 180
        
      let height = cellPadding * 2 + columnWidth * ratio
      let frame = CGRect(x: xOffset[column],
                         y: yOffset[column],
                         width: columnWidth,
                         height: height)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        
      // 5 create attribute
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
        
      // 6 update contentHeight to be the max height of all
      contentHeight = max(contentHeight, frame.maxY)
      yOffset[column] = yOffset[column] + height
      
      column = column < (numberOfColumns - 1) ? (column + 1) : 0
    }
  }

  // Which item is visible on the screen
  override func layoutAttributesForElements(in rect: CGRect)
      -> [UICollectionViewLayoutAttributes]? {
    var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    // Loop through the cache and look for items in the rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  // Actually return the attribute for that indexPath
  override func layoutAttributesForItem(at indexPath: IndexPath)
      -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }


}
