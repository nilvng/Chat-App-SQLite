//
//  PhotoViewController.swift
//  PinterestView
//
//  Created by LAP11353 on 28/03/2022.
//

import UIKit
import Photos

class MediaViewController: UIViewController {
    
    
    var imageView = UIImageView()
    var progressView = UIProgressView()
    var mediaPrep : MediaPrep!
    var message: MessageDomain!
    var index: Int!
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    var player : AVPlayer?
    var playButton : UIButton = UIButton()
    var isPlaying : Bool = false {
        didSet {
            // animate play button
        }
    }
    fileprivate var playerLayer: AVPlayerLayer!
    var slider : UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressView)
        progressView.centerInSuperview()

        setupImageView()
        setupPlayButton()
        setupNavigationView()
        setupSlider()
//        view.backgroundColor = UIColor(r: 111, g: 97, b: 108)
    }
    
    func setupSlider(){
        let slider = UISlider()
        view.addSubview(slider)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = true
        slider.tintColor = .purple
        slider.addConstraints(leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, widthConstant: 50)
        self.slider = slider
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
        playButton.setImage(UIImage(systemName: "play"), for: .normal)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .highlighted)
        playButton.setImage(UIImage(systemName: "pause"), for: .selected)

        playButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
    }

    
    @objc func play(){
//        print("Play!")
        guard mediaPrep.type == .video else {
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
            setupProgressTimer()
            DispatchQueue.main.async { [self] in
                
                guard self.playerLayer == nil else { return }
                
                // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                guard let videoURL = mediaWorker.url(index: index, of: message,
                                                     isExist: true) else {return}
                self.player = AVPlayer(url: videoURL)
                let playerLayer = AVPlayerLayer(player: player)

                // Configure the AVPlayerLayer and add it to the view.
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                playerLayer.frame = self.view.layer.bounds
                self.view.layer.addSublayer(playerLayer)
                self.view.bringSubviewToFront(self.playButton)
                self.player?.play()
                
                // Cache the player layer by reference, so you can remove it later.
                self.playerLayer = playerLayer
                
            }
        }
    }
    
    func setupNavigationView(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(save))
        navigationController?.hidesBarsOnTap = true

    }
    
    @objc func save(){
        print("saving...")
    }
    
    private func setupProgressTimer() {
        var _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (completion) in
            guard let self = self else { return }
            self.updateProgress()
        })
    }

    //update progression of video, based on it's own data

    private func updateProgress() {
        guard let duration = player?.currentItem?.duration.seconds,
            let currentMoment = player?.currentItem?.currentTime().seconds else { return }

        slider.setValue(Float(currentMoment * 100.0 / duration), animated: true)
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
  
    func configure(i: Int, of message: MessageDomain){
        self.message = message
        self.index = i

        if let prep = message.getPrep(index: i),
            let bgColor = prep.bgColor{
            self.mediaPrep = prep
            let color = UIColor.rgb(red: CGFloat(bgColor.red),
                                    green: CGFloat(bgColor.green),
                                    blue: CGFloat(bgColor.blue),
                                    alpha: CGFloat(bgColor.alpha))
            navigationController?.navigationBar.tintColor = .blue
            view.backgroundColor = color
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard mediaPrep != nil else{
            return
        }
        if mediaPrep.type == .video {
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .blue
        navigationController?.hidesBarsOnTap = false

    }

}
