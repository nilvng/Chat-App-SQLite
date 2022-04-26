//
//  PhotoViewController.swift
//  PinterestView
//
//  Created by LAP11353 on 28/03/2022.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {
    
    var asset : PHAsset!
    
    var imageView = UIImageView()
    var progressView = UIProgressView()

    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    
    var playButton : UIButton = UIButton()
    var isPlaying : Bool = false {
        didSet {
            // animate play button
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressView)
        progressView.centerInSuperview()

        setupImageView()
        setupPlayButton()
        setupNavigationView()
//        view.backgroundColor = UIColor(r: 111, g: 97, b: 108)
    }
    
    
    func setupImageView(){
        view.addSubview(imageView)
        imageView.addConstraints(top: view.topAnchor, leading: view.leadingAnchor,
                                 bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        imageView.contentMode = .scaleAspectFit
    }
    func setupPlayButton(){
        view.addSubview(playButton)
        playButton.centerInSuperview()
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .highlighted)
        playButton.setImage(UIImage(systemName: "pause.circle"), for: .selected)

        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
    }
    fileprivate var playerLayer: AVPlayerLayer!

    
    @objc func play(){
        guard asset.mediaType == .video else {
            return
        }
        playButton.isSelected = !playButton.isSelected
        if playerLayer != nil {
            // The app already created an AVPlayerLayer, so tell it to play.
            if playButton.isSelected {
                playerLayer.player!.play()
            } else {
                playerLayer.player?.pause()
            }
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            options.progressHandler = { progress, _, _, _ in
                // The handler may originate on a background queue, so
                // re-dispatch to the main queue for UI work.
                DispatchQueue.main.sync {
                    self.progressView.progress = Float(progress)
                }
            }
            // Request an AVPlayerItem for the displayed PHAsset.
            // Then configure a layer for playing it.
            PHImageManager.default().requestPlayerItem(forVideo: asset,
                                                       options: options,
                                                       resultHandler: { playerItem, info in
                DispatchQueue.main.async {
                    guard self.playerLayer == nil else { return }
                    
                    // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    
                    // Configure the AVPlayerLayer and add it to the view.
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    playerLayer.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(playerLayer)
                    self.view.bringSubviewToFront(self.playButton)
                    player.play()
                    
                    // Cache the player layer by reference, so you can remove it later.
                    self.playerLayer = playerLayer
                }
            })
        }
    }
    
    func setupNavigationView(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(save))
        navigationController?.hidesBarsOnTap = true

    }
    
    @objc func save(){
        print("saving...")
    }

    
    fileprivate func configureBGColor(_ im: UIImage) {
        guard let bgColor = im.averageColor else {return}
        navigationController?.navigationBar.tintColor = .blue
        view.backgroundColor = bgColor.darker()
        navigationController?.backgroundColor(bgColor)
    }
    
    func configure(with im: UIImage){
        imageView.image = im
        configureBGColor(im)
    }
    
    func configure(with asset: PHAsset){
        self.asset = asset
        updateStaticImage(asset: asset, callback: { im in
            self.configureBGColor(im)
        })
        
    }
    func configure(i: Int, of message: MessageDomain){
        if let prep = message.getPrep(index: i), let bgColor = prep.bgColor{
            let color = UIColor.rgb(red: CGFloat(bgColor.red),
                                    green: CGFloat(bgColor.green),
                                    blue: CGFloat(bgColor.blue),
                                    alpha: CGFloat(bgColor.alpha))
            navigationController?.navigationBar.tintColor = .blue
            view.backgroundColor = color.darker()
            navigationController?.backgroundColor(color)

        }
        updateStaticImage(i: i, of: message)
        
    }
    
    lazy var mediaWorker : MediaWorker = MediaWorker.shared
    func updateStaticImage(i: Int, of message: MessageDomain) {
        Task{
            do{
                let im = try await mediaWorker.image(index: i, of: message, type: .original)
                self.imageView.image = im
            } catch {
                print("Can't load image from storage!!!")
            }
        }
    }
    
    func updateStaticImage(asset: PHAsset, callback: @escaping (UIImage) -> Void) {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options,
                                              resultHandler: { image, _ in
                                                // PhotoKit finished the request, so hide the progress view.
                                                self.progressView.isHidden = true
                                                
                                                // If the request succeeded, show the image view.
                                                guard let image = image else { return }
                                                
                                                // Show the image.
                                                self.imageView.isHidden = false
                                                self.imageView.image = image
                                                callback(image)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.tintColor = .white
//        if asset.mediaType == .video {
//            playButton.isHidden = false
//            play()
//        } else {
//            playButton.isHidden = true
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .blue
        navigationController?.hidesBarsOnTap = false

    }

}
