//
//  MessageCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessageCell: UITableViewCell {
    
    typealias MessageCellAction = (MessageCell) -> Void
    
    var interactor : MessageCellInteractor?
    
    lazy var friendSerivce : FriendService = NativeContactStoreAdapter.shared
    var message : MessageDomain!
    var downloadAction : MessageCellAction?
    
    static let identifier = "MessageCell"
    var inboundConstraint : NSLayoutConstraint!
    var outboundConstraint : NSLayoutConstraint!
    var continuousConstraint : NSLayoutConstraint!
    var downloadConstraint : NSLayoutConstraint!
    var notDownloadConstraint : NSLayoutConstraint!

    
    let messageBodyLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.backgroundColor = .clear
        return label
    }()
    let timestampLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    

    
    var bubbleImageView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var avatarView : AvatarView = {
        let view = AlamoAvatarView(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var downloadButton : DownloadBtnView = DownloadBtnView()
    
    var incomingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = UIColor.trueLightGray
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()
    
    var outgoingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = .none
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bubbleImageView)
        contentView.addSubview(avatarView)
        contentView.addSubview(messageBodyLabel)

        setupAvatarView()
        setupMessageBody()
        setupBubbleBackground()
        setupDownloadButton()
        
        setInteractor()
                
        }
    
    // MARK: Configuration

    func setInteractor(){
        interactor = MessageCellInteractor()
        interactor?.presenter = self
    }
    
    func configure(with model: MessageDomain, lastContinuousMess: Bool = false){
        
        backgroundView = .none
        backgroundColor = .clear

        message = model
        model.subscribe(self)
        
        let isReceived = isReceived(sender: model.sender)
        // Style bubble based on the type content
        switch model.type {
        case .text:
            styleDownloadbleBubble(isIt: false)
            messageBodyLabel.text = model.content
        case .file:
            styleDownloadbleBubble(isIt: true, content: model.content, isReceived: isReceived)
        default:
            styleDownloadbleBubble(isIt: false)
            messageBodyLabel.text = "Unprocessed bubble:" + model.content
        }

        // Align bubble based on whether the sender is the user themselves
        if !isReceived {
            alignSentBubble()
        } else {
            alignReceivedBubble(lastContinuousMess, model)
        }
        // Continuous message would be closer to each other
        continuousConstraint.constant = lastContinuousMess ? bubbleVPadding - 4 : bubbleVPadding

    }
    
    func isReceived(sender: String) -> Bool{
        //print("sender: \(sender)")
        return sender != UserSettings.shared.getUserID()
    }
    
    // MARK: Style bubble
    
    func styleDownloadbleBubble(isIt: Bool, content: String = "", isReceived: Bool = false){
        // show download button next to content message
        let size : CGFloat = 16
        messageBodyLabel.font = isIt ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
        messageBodyLabel.text = content
        
        let showDownload = isIt && isReceived
        
        downloadButton.isHidden = !showDownload
        
        if message!.downloaded {
            downloadButton.progressTo(val: 1)
        } else {
            downloadButton.progressTo(val: 0)
        }
        
        
    }
    fileprivate func alignSentBubble() {
        // get bubble
        bubbleImageView.image = BackgroundFactory.shared.getBackground(config: outgoingBubbleConfig)
        // sent message will align to the right
        inboundConstraint?.isActive = false
        outboundConstraint?.isActive = true
        // remove avatar view as message is sent by me
        avatarView.isHidden = true
        // bubble will have color so, text color = .white
        messageBodyLabel.textColor = .white
    }
    
    fileprivate func alignReceivedBubble(_ lastContinuousMess: Bool, _ model: MessageDomain) {
        // get the bubble image
        bubbleImageView.image = BackgroundFactory.shared.getBackground(config: incomingBubbleConfig)
        // received message will align to the left
        outboundConstraint?.isActive = false
        inboundConstraint?.isActive = true
        messageBodyLabel.textColor = .black
        // show avatar view if is the last continuous message a friend sent
        avatarView.isHidden = !lastContinuousMess
        
        if lastContinuousMess{
            showAvatar(fid: model.sender)
        }
    }
    
    func showAvatar(fid: String){
        friendSerivce.fetchItemWithId(fid, completionHandler: { res, err in
            if let friend = res {
                let url = friend.avatar
                DispatchQueue.main.async {
                    self.avatarView.update(url: url, text: friend.name)
                }
            } else {
                print("Error fetching friend: \(fid)")
            }
        })


    }
    var bubbleVPadding : CGFloat = BubbleConstant.vPadding
    var bubbleHPadding : CGFloat = BubbleConstant.hPadding

    
    
    func updateGradient(currentFrame: CGRect, theme: Theme){
        
        guard !isReceived(sender: message.sender) else {
            return
        }
        let normalizedY = currentFrame.maxY
        
        if normalizedY < 0 {
            print(normalizedY)
            return
        }

        let color = theme.gradientImage.getPixelColor(pos: CGPoint(x:10 , y: normalizedY))
        self.bubbleImageView.tintColor = color
    }
    
    // MARK: Setup views
    
    func setupMessageBody(){
        messageBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.outboundConstraint =  messageBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bubbleHPadding)
        self.inboundConstraint = messageBodyLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: bubbleHPadding)
        self.continuousConstraint = messageBodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: bubbleVPadding)

        let constraints : [NSLayoutConstraint] = [
            messageBodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bubbleVPadding),
            continuousConstraint,
            outboundConstraint,
            inboundConstraint,
            messageBodyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: BubbleConstant.maxWidth),
        ]
        messageBodyLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate(constraints)

    }
    
    func setupBubbleBackground(){
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            bubbleImageView.topAnchor.constraint(equalTo: messageBodyLabel.topAnchor, constant: -bubbleVPadding + BubbleConstant.contentVPadding),
            bubbleImageView.leadingAnchor.constraint(equalTo: messageBodyLabel.leadingAnchor, constant: -bubbleHPadding + BubbleConstant.contentHPadding),
            bubbleImageView.bottomAnchor.constraint(equalTo:  messageBodyLabel.bottomAnchor, constant: bubbleVPadding - BubbleConstant.contentVPadding),
            bubbleImageView.trailingAnchor.constraint(equalTo: messageBodyLabel.trailingAnchor, constant: bubbleHPadding - BubbleConstant.contentHPadding),
        ]
        
        NSLayoutConstraint.activate(constraints)
        }
    
    func setupAvatarView(){
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            avatarView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BubbleConstant.contentHPadding),
            avatarView.widthAnchor.constraint(equalToConstant: BubbleConstant.avatarSize),
            avatarView.heightAnchor.constraint(equalToConstant: BubbleConstant.avatarSize)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    func setupDownloadButton(){
        contentView.addSubview(downloadButton)
        downloadButton.delegate = self
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            downloadButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            downloadButton.leadingAnchor.constraint(equalTo: bubbleImageView.trailingAnchor, constant: 0),
            downloadButton.widthAnchor.constraint(equalToConstant: 35),
            downloadButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
    }
    
    func setupTimestampLabel(){
        contentView.addSubview(timestampLabel)
        timestampLabel.translatesAutoresizingMaskIntoConstraints  = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - DownloadBtnDelegate
extension MessageCell : DownloadBtnDelegate {
    func start() {
        downloadAction?(self)
        interactor?.downloadMessage(message)
    }
}

extension MessageCell : MessageCellPresenter {
    
    //MARK: - MessageSubscriber
    func progressTo(val: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.downloadButton.progressTo(val: val)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        message?.dropSubscriber()
    }
}


