//
//  CollageLayout.swift
//  PinterestView
//
//  Created by LAP11353 on 31/03/2022.
//

import UIKit


protocol CollageLayoutDelegate: AnyObject {
    func collectionView(
      _ collectionView: UICollectionView,
      ratioHWForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class CollageLayout: UICollectionViewLayout {
  // 1 to ask for the height of the image
  weak var delegate: CollageLayoutDelegate?
    var alignRight : Bool = true
  // 2 necessary variables to layout collection view
  private let numberOfColumns = 3
  private let cellPadding: CGFloat = 1

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
      let rowHeight : CGFloat = 70
      var row = 0
      var xOffset : CGFloat = 0
      let noItems = collectionView.numberOfItems(inSection: 0)
    // 3 go through every item
      for item in 0..<noItems{
          let indexPath = IndexPath(item: item, section: 0)
          
          // 4 calculate width
          let ratio = delegate?.collectionView(
            collectionView,
            ratioHWForPhotoAtIndexPath: indexPath) ?? 1
          
          let yOffset = CGFloat(row) * rowHeight
          
          var width =  rowHeight / ratio
          
          if (contentWidth - width - xOffset) < (contentWidth / 5) {
//              print("expand... \(item)")
              width = contentWidth - xOffset
          }
          
          if alignRight  && item == noItems - 1  && xOffset == 0 {
 
                  xOffset = contentWidth - width
              
          }
//          print("width: \(width) height: \(rowHeight)")

       
          let frame = CGRect(x: xOffset,
                             y: yOffset,
                             width: width,
                             height: rowHeight)
          let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
          
          // 5 create attribute
          let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
          attributes.frame = insetFrame
          cache.append(attributes)
          
          // 6 update contentHeight to be the max height of all
          contentHeight = max(contentHeight, frame.maxY)
          
          
          if xOffset + width >= contentWidth{
              xOffset = 0
              row += 1
          }
          else {
              xOffset += width
              
          }
          
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
