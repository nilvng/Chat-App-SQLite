//
//  LocalGalleryService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 12/04/2022.
//

import Foundation
import Photos
import PhotosUI


protocol LocalGalleryServiceDelegate : AnyObject{
    func photoDidChange(_ changes: PHFetchResultChangeDetails<PHAsset>)
}

class LocalGalleryService : NSObject{
    
    var fetchResult: PHFetchResult<PHAsset>? = nil
    var thumbnailSize: CGSize = .zero
    
    fileprivate let imageManager = PHCachingImageManager()
    var preheatRect : CGRect = .zero
    weak var delegate : LocalGalleryServiceDelegate?
    
    override init(){
        super.init()
        PHPhotoLibrary.shared().register(self)

    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    func get(at i: Int) -> PHAsset? {
        fetchResult?.object(at: i) ?? nil
    }
    
    func getSize() -> Int {
        return fetchResult?.count ?? 0
    }
}

extension LocalGalleryService : PhotoLibraryInteractor {
    func getAsset(at i: Int) -> PHAsset? {
        guard let result = fetchResult else {
            return nil
        }
        return result.object(at: i)
    }
    
    
    func setThumbnailSize(to size: CGSize){
        
    }
    
    func fetchData(completion: @escaping (Int) -> Void){
        // TODO: use private queue
        
        DispatchQueue.global().async { [weak self] in
            if self?.fetchResult == nil {
                let allPhotosOptions = PHFetchOptions()
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                self?.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
                completion(self?.fetchResult?.count ?? 0)
            }
        }
    }

    func updateCachedAssets(collectionView: UICollectionView, viewHeight: CGFloat){
        
        guard let fetchResult = fetchResult else {
            return
        }

        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - self.preheatRect.midY)
        guard delta > viewHeight / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(self.preheatRect, preheatRect)
        let addedAssets = addedRects
            .compactMap { rect in collectionView.indexPathForItem(at: rect.origin) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .compactMap { rect in collectionView.indexPathForItem(at: rect.origin) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        self.preheatRect = preheatRect
    }
    
    func resetCaches(){
        imageManager.stopCachingImagesForAllAssets()
        preheatRect = .zero
    }
    func requestImage(for asset: PHAsset, resultHandler: @escaping (UIImage?) -> Void){
        // TODO: Use thumbnail of asset
        let option = PHImageRequestOptions()
        option.deliveryMode = .opportunistic
        option.isNetworkAccessAllowed = true
        imageManager.requestImage(for: asset, targetSize: thumbnailSize,
                                     contentMode: .aspectFill, options: option,
                                     resultHandler: { im, _ in
            resultHandler(im)
        })
    }
    
    
    func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
}

extension LocalGalleryService :  PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let og = fetchResult else {
            return
        }
        guard let changes = changeInstance.changeDetails(for: og)
            else { return }
        fetchResult = changes.fetchResultAfterChanges
        delegate?.photoDidChange(changes)
        resetCaches()
    }
}
