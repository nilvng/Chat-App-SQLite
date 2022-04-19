//
//  PhotoCollectionViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/03/2022.
//

import UIKit

private let reuseIdentifier = "PhotoCell"

//
//  LocalPhotosViewController.swift
//  PinterestView
//
//  Created by LAP11353 on 28/03/2022.
//

import UIKit
import Photos
import PhotosUI

protocol PhotoLibraryInteractor {
    func setThumbnailSize(to: CGSize)
    func fetchData(completion: @escaping (Int) -> Void)
    func updateCachedAssets(collectionView: UICollectionView,  viewHeight: CGFloat)
    func getAsset(at: Int) -> PHAsset?
    func getSize() -> Int
    func requestImage(for asset: PHAsset, resultHandler: @escaping (UIImage?) -> Void)
}
class PhotoGalleryViewController: UIViewController {

    var interactor : PhotoLibraryInteractor!
    @IBOutlet weak var albumViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalPhotoLabel: UILabel!
    var totalPhotos : Int = 0 {
        didSet {
            if isViewLoaded {
                totalPhotoLabel.text = "Total photos: \(totalPhotos)"
            }
        }
    }

    @IBOutlet weak var promptMorePhotoView: UIStackView!
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
   
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    fileprivate var thumbnailSize: CGSize!
    
    
    typealias CompletionCallback  = ([PHAsset]) -> Void
    var callback : CompletionCallback?
    var hasFullAccess : Bool = true
    
    var currentNOSelect = 0 {
        didSet {
            if currentNOSelect == 0 {
                submitButton.isHidden = true
            } else {
                submitButton.isHidden = false
            }
        }
    }
    var selectedIndices : [IndexPath] = []
    
    var numberOfItemsInRow = 3
    var cellPadding : CGFloat = 1
    
    
    init(){
        super.init(nibName: "LocalGalleryView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        submitButton.isHidden = true
        
        promptMorePhotoView.isHidden = hasFullAccess
        
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        interactor?.setThumbnailSize(to: thumbnailSize)
        
    }
    
    func setupInteractor(_ inter: LocalGalleryService){
//        let service = LocalGalleryService()
        inter.delegate = self
        interactor = inter
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LocalPhotoCell.self, forCellWithReuseIdentifier: LocalPhotoCell.identifier)
    }
    
    @IBAction func submit(){
        var assets : [PHAsset] = []
        for i in selectedIndices {
            guard let asset = interactor.getAsset(at: i.item) else {
                continue
            }
            assets.append(asset)
        }
        dismiss(animated: true)
        callback?(assets)

    }
    @IBAction func morePhotosTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "",
                                               message: "Select more photos or go to Settings to allow access to all photos.",
                                               preferredStyle: .actionSheet)
           
           let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                                  style: .default) { [unowned self] (_) in
               // Show limited library picker
               PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
           }
           actionSheet.addAction(selectPhotosAction)
           
           let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                     style: .default) { [unowned self] (_) in
               // Open app privacy settings
               gotoAppPrivacySettings()
           }
           actionSheet.addAction(allowFullAccessAction)
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           actionSheet.addAction(cancelAction)
           
           present(actionSheet, animated: true, completion: nil)
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
    func configure(completion: @escaping ([PHAsset]) -> Void){
        callback = completion
    }

    var originalCenter : CGPoint!
}

// MARK: - CollectionView Delegate, Data Source
extension PhotoGalleryViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let c = collectionView.cellForItem(at: indexPath) as? LocalPhotoCell else {
            return
        }
        if c.isAlreadySelected {
            c.unselect()
            currentNOSelect -= 1
            let i = selectedIndices.firstIndex(where: {$0.row == indexPath.row && $0.section == indexPath.section})!
            for ptr in i+1..<selectedIndices.count{
                guard let cell = collectionView.cellForItem(at: selectedIndices[ptr]) as? LocalPhotoCell else {
                    continue
                }
                cell.select(number: ptr)
            }
            selectedIndices.remove(at: i)
            
        } else {
            currentNOSelect += 1
            selectedIndices.append(indexPath)
            c.select(number: currentNOSelect)
        }
        submitButton.setTitle("SEND \(currentNOSelect)", for: .normal)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        interactor.getSize()
    }
    /// - Tag: PopulateCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let asset = interactor.getAsset(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocalPhotoCell.identifier, for: indexPath) as? LocalPhotoCell
            else { fatalError("Unexpected cell in collection view") }
        
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        var duration : Int? = nil
        if asset.mediaType == .video {
            duration = Int(asset.duration.rounded(.up))
            print(duration)
        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.startLoading()
        interactor.requestImage(for: asset, resultHandler: { image in
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.stopLoading()
                cell.configure(with: image, videoDuration: duration)
            }
        })
        return cell
    }
    
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
}
// MARK: - UIFlowLayoutDelegate
extension PhotoGalleryViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (Int(UIScreen.main.bounds.size.width) - (numberOfItemsInRow - 1) * Int(cellPadding)) / numberOfItemsInRow
//        let width: CGFloat = (self.view.frame.width / 3)
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }
}

extension PhotoGalleryViewController : LocalGalleryServiceDelegate{

    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        interactor.updateCachedAssets(collectionView: self.collectionView, viewHeight: view.bounds.height)
        
    }
    func photoDidChange(_ changes: PHFetchResultChangeDetails<PHAsset>){

        //TODO: Get asset to be update (id, )
        DispatchQueue.main.sync {
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
//                    changes.insertedObjects
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            totalPhotos = interactor?.getSize() ?? 0
        }
    }

}


