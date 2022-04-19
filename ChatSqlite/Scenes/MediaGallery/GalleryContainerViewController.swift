//
//  GalleryContainerViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 12/04/2022.
//


import UIKit
import Photos

class GalleryContainerViewController: UIViewController {
    
    fileprivate let fullVC = PhotoGalleryViewController()
    fileprivate lazy var noVC = NoAccessViewController()
    var label = UILabel()

    typealias SelectedCallback = ([PHAsset]) -> Void
    var callback : SelectedCallback?
    
    private var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    enum State {
        case fullAccess, limitAccess, noAccess
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(label)
        label.centerInSuperview()
        label.text = "Loading image from you local gallery..."
        
        self.checkPermission()
        noVC.callback = {
            self.checkPermission()
        }
    }
    
    func checkPermission(){
        // TODO:
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
                updateTo(status)
            }
        }
    }
    
    func updateTo(_ state: PHAuthorizationStatus){
        switch state {
        case .authorized:
            showGallery(hasFull: true)
        case .limited:
            showGallery(hasFull: false)
        case .restricted:
            break
        case .denied, .notDetermined:
            activeViewController = noVC
        default:
            break
        }
    }
    
    func showGallery(hasFull: Bool){
        // TODO: Pass data to Gallery, not let them fetch data
        let inter = LocalGalleryService()
        inter.fetchData(completion: { [weak self] total in
            
            DispatchQueue.main.async {
                if total > 0 {
                    self?.fullVC.setupInteractor(inter)
                    // selected images
                    self?.fullVC.configure(completion: { assets in
                        self?.callback?(assets)
                    })
                    self?.fullVC.hasFullAccess = hasFull
                    self?.activeViewController = self?.fullVC
                    
                }
            }
        })

    }

    private func removeInactiveViewController(_ inactiveViewController: UIViewController?) {
        if isViewLoaded {
            if let inActiveVC = inactiveViewController {
                inActiveVC.willMove(toParent: nil)
                inActiveVC.view.removeFromSuperview()
                inActiveVC.removeFromParent()
            }
        }
    }

    private func updateActiveViewController() {
        if isViewLoaded {
            if let activeVC = activeViewController {
                addChild(activeVC)
                activeVC.view.frame = view.bounds
                view.addSubview(activeVC.view)
                activeVC.didMove(toParent: self)
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
