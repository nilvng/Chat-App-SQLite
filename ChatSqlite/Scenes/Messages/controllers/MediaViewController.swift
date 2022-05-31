//
//  PhotoViewController.swift
//  PinterestView
//
//  Created by LAP11353 on 28/03/2022.
//

import UIKit
import Photos

class MediaViewController: UIViewController {
    
    enum PlayerState {
        case isSeeking, isPlaying, pause, donePlaying
    }
    
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
    var playerState : PlayerState = .pause
    
    var sliderAnimator : UIViewPropertyAnimator?
    
    var durationLabel : UILabel = UILabel()
    var durationHour : Int?
    var durationMinute : Int?
    
    var timeObserverToken : Any?
    fileprivate var playerLayer: AVPlayerLayer!
    var slider : UISlider!
    var videoProgressBarView : VideoProgressBarView?
    var navBarView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressView)
        progressView.centerInSuperview()
//        navigationController?.navigationBar.tintColor = .white
        setupImageView()
        setupNav()
        setupPlayButton()
        setupSlider()
    }
    
    // MARK: Setups
    func setupSlider(){
        let slider = UISlider()
        view.addSubview(slider)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = false
        slider.tintColor = .purple
        slider.addConstraints(leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        slider.addTarget(self, action: #selector(timeSliderDidChange), for: [.valueChanged])
        slider.addTarget(self, action: #selector(sliderDragEnded), for: .touchDown)
        self.slider = slider
    }
    
    func setupVideoProgressBar(){
        videoProgressBarView = VideoProgressBarView()
        videoProgressBarView?.isUserInteractionEnabled = true
        self.view.addSubview(videoProgressBarView!)
        videoProgressBarView?.addConstraints(leading: self.view.leadingAnchor, bottom: self.slider.topAnchor, trailing: self.view.trailingAnchor)
    }
    
    func setupTimeLabel(){
        
    }
    
    @objc func tapBar(){
        print("tap...")
    }
    
    func setupNav(){
        view.addSubview(navBarView)
        navBarView.addConstraints(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, heightConstant: 65)
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .white
        
        navBarView.addSubview(backButton)
        backButton.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 5).isActive = true
        backButton.constraint(equalTo: CGSize(width: 30, height: 30))
        backButton.addTarget(self, action: #selector(popView), for: .touchUpInside)
    }
    
    @objc func popView(){
        dismiss(animated: true)
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

        playButton.addTarget(self, action: #selector(playButtonTap), for: .touchUpInside)
    }
    
    func setupNavigationView(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(save))
        navigationController?.hidesBarsOnTap = true

    }

    // MARK: - Actions
    @objc func timeSliderDidChange(sender: UISlider, event: UIEvent){
        let prevState = playerState
        setPlayerStatus(to: .isSeeking)
        guard let duration = player?.currentItem?.duration.seconds else {
            return
        }
        let time = Double(sender.value) * duration / 100
        let newTime = CMTime(seconds: Double(time), preferredTimescale: 600)
        let tolerBefore = CMTime(seconds: 1.0, preferredTimescale: 600)
        let tolerAfter = CMTime(seconds: 1.0, preferredTimescale: 600)

        player?.seek(to: newTime, toleranceBefore: tolerBefore, toleranceAfter: tolerAfter)
        setPlayerStatus(to: .isPlaying)
    }
    
    @objc func sliderDragEnded(sender: UISlider){
        setPlayerStatus(to: .isSeeking)
        print("touch down")
    }
    
    private var playerItemContext = 0
    
    @objc func playButtonTap(){
//        print("Play!")
        guard mediaPrep.type == .video else {
            return
        }
        playButton.isSelected = !playButton.isSelected
        if playerLayer != nil {
            // The app already created an AVPlayerLayer, so tell it to play.
            if playButton.isSelected {
                setPlayerStatus(to: .isPlaying)
            } else {
                setPlayerStatus(to: .pause)
            }
        } else {
            DispatchQueue.main.async { [self] in
                
                guard self.playerLayer == nil else { return }
                
                // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                guard let videoURL = mediaWorker.url(index: index, of: message,
                                                     isExist: true) else {return}
                self.player = AVPlayer(url: videoURL)
                // Register as an observer of the player item's status property
//               player!.addObserver(self,
//                                   forKeyPath: #keyPath(AVPlayerItem.status),
//                                      options: [.old, .new],
//                                      context: &playerItemContext)
                
                let playerLayer = AVPlayerLayer(player: player)

                // Configure the AVPlayerLayer and add it to the view.
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                playerLayer.frame = self.view.layer.bounds
                self.view.layer.addSublayer(playerLayer)
                self.view.bringSubviewToFront(self.playButton)
                
                // Cache he player layer by reference, so you can remove it later
                
                self.playerLayer = playerLayer
                startUpdatingPlaybackStatus()
                if let duration = player?.currentItem?.asset.duration.seconds{
                videoProgressBarView?.configure(duration: duration)
                }
                // setup animator
                setPlayerStatus(to: .isPlaying)
                
            }
        }
    }
    func startUpdatingPlaybackStatus(){
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(seconds: 1, preferredTimescale: timeScale)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval,
                                                            queue: .main, using: { [weak self] curTime in
            self?.updateProgress()
        })
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func play(){
//        displayLink.isPaused = false
        playerLayer.player?.play()
        videoProgressBarView?.play()
    }

    func stopUpdatingPlaybackStatus() {
    }
    func pause(){
        // Pause
        playerLayer.player?.pause()
        videoProgressBarView?.pause()
//        displayLink.isPaused = true
    }
    
    func setPlayerStatus(to status : PlayerState){
        self.playerState = status
        switch status {
        case .isSeeking:
//            displayLink.isPaused = true
            break
        case .isPlaying:
            play()
        case .pause:
            pause()
        case .donePlaying:
            print("done")
        }
    }

    
    @objc func save(){
        print("saving...")
    }
    
    
    // MARK: - Update Player
    //update progression of video, based on it's own data

    @objc func updateProgress() {
        guard let duration = player?.currentItem?.duration.seconds,
            let curTime = player?.currentItem?.currentTime().seconds,
        player?.status == .readyToPlay else { return }
        
        guard playerState == .isPlaying else {
            return
        }
        
        if curTime == duration {
            stopUpdatingPlaybackStatus()
        }
        let playbackProgress = Float(curTime / duration) * 100.0
//        print(playbackProgress)
        UIView.animate(withDuration: 1, animations: {
            self.slider.setValue(playbackProgress, animated: true)
        })
    }
    
    

    // MARK: - Configuration
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
//        self.imageView.image = UIImage(named: "default")
        
        updateStaticImage(i: i, of: message)
        
    }
    
    
    lazy var mediaWorker : MediaWorker = MediaWorker.shared
    
    func updateStaticImage(i: Int, of message: MessageDomain) {
        Task{
            do{
                let im = try await mediaWorker.image(index: i, of: message, type: .original)
                self.imageView.image = im
                print("finished load fullsize image")
            } catch {
                print("Can't load image from storage!!!")
            }
        }
    }
    
    // MARK: - Navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard mediaPrep != nil else{
            return
        }
        if mediaPrep.type == .video {
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
            slider.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .blue
        navigationController?.hidesBarsOnTap = false
        sliderAnimator?.stopAnimation(false)

    }

}

// MARK: - AnimatableViewController
extension MediaViewController : PopAnimatableViewController {
    func getSourceSnapshot() -> UIView? {
        return nil
    }
    
    func getWindow() -> UIWindow? {
        view.window
    }
    

    func getView() -> UIView {
        return view
    }
    
    func getAnimatableView() -> UIView {
        return imageView
    }
    
    func animatableViewRect() -> CGRect {
        
        guard let scaleHW = mediaPrep.ratioHW else {
            let window = self.view.window
            let rect = imageView.convert(imageView.bounds, to: window)
            return rect
        }
        let trueH = view.bounds.width * scaleHW
        let trueW = view.bounds.width
        let y = (Double(view.bounds.height) / 2) - trueH / 2
        let updated = CGRect(x: 0, y: y, width: trueW, height: trueH)
        return updated
    }
    
    
}
