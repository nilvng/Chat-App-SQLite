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
    
    var message : MessageDomain!
    var index: Int!
    
    var downloadAction : MessageCellAction?
    
    static let identifier = "MessageCell"
    var inboundConstraint : NSLayoutConstraint!
    var outboundConstraint : NSLayoutConstraint!
    var continuousConstraint : NSLayoutConstraint!
    var downloadConstraint : NSLayoutConstraint!
    var notDownloadConstraint : NSLayoutConstraint!
    var bubbleWidth = BubbleConstant.maxWidth

    
    var statusImage = UIImageView()
    
    var messageContainerView = UIView()
    
    let timestampLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    

    
//    var bubbleImageView : UIImageView = {
//        let imageView = UIImageView()
//        return imageView
//    }()
    
    var avatarView : AvatarView = {
        let view = AlamoAvatarView(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var downloadButton : DownloadBtnView = DownloadBtnView()
    
    var incomingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = UIColor.trueLightGray
        config.corner = [.topRight, .bottomRight, .topLeft]
        config.radius = 14
        return config
    }()
    
    var outgoingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = .none
        config.corner = [.topLeft, .bottomLeft, .topRight]
        config.radius = 14
        return config
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(statusImage)
//        contentView.addSubview(bubbleImageView)
        contentView.addSubview(avatarView)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(timestampLabel)

        setupAvatarView()
        setupMessageBody()
        setupStatusImage()
//        setupDownloadButton()

        backgroundView = .none
        backgroundColor = .clear
        setInteractor()
                
        }
    
    // MARK: Configuration
    
    var bubbleVPadding : CGFloat = BubbleConstant.vPadding
    var bubbleHPadding : CGFloat = BubbleConstant.hPadding
    
    func setInteractor(){
        interactor = MessageCellInteractor()
        interactor?.presenter = self
    }

    
    func configure(with model: MessageDomain, indexPath: IndexPath,
                   isStartMessage isStart: Bool, isEndMessage isEnd: Bool){

        message = model
        index = indexPath.item
        model.subscribe(self)
        
        let isReceived = isReceived(sender: model.sender)

        // Align bubble based on whether the sender is the user themselves

        if !isReceived {
            alignSentBubble()
            let config = outgoingBubbleConfig
//            bubbleImageView.image = BackgroundFactory.shared.getBackground(config: config)
            
            if let symbol = model.status.getSymbol(){
                statusImage.isHidden = false
                statusImage.image = symbol
            }
            
        } else {
            statusImage.isHidden = true
            alignReceivedBubble(isStart, model)
            let config = incomingBubbleConfig
//            bubbleImageView.image = BackgroundFactory.shared.getBackground(config: config)
        }
        
        if model.status == .seen{
            if indexPath.section == 0 && indexPath.row == 0 {
                statusImage.isHidden = false
            } else {
                statusImage.isHidden = true
            }
        }
        
        
        // Continuous message would be closer to each other
        continuousConstraint.constant = isEnd ? bubbleVPadding : bubbleVPadding - 4


    }
    
    func updateStatus(to status: MessageStatus){
        if !statusImage.isHidden {
            statusImage.image = status.getSymbol()
        }
    }
    
    func formatTimestamp(isStart: Bool, model: MessageDomain){
        if isStart {
            // show timestamp
            timestampLabel.isHidden = false
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timestampLabel.text = formatter.string(from: model.timestamp)

        } else {
            timestampLabel.isHidden = true
        }
    }
    
    func isReceived(sender: String) -> Bool{
        //print("sender: \(sender)")
        return sender != UserSettings.shared.getUserID()
    }
    
    // MARK: Style bubble
    
    func styleDownloadbleBubble(isIt: Bool, content: String = "", isReceived: Bool = false){
        // show download button next to content message
        let showDownload = isIt && isReceived
        downloadButton.isHidden = !showDownload
        
        if message!.downloaded {
            downloadButton.progressTo(val: 1)
        } else {
            downloadButton.progressTo(val: 0)
        }
        
    }
    fileprivate func alignSentBubble() {
        // sent message will align to the right
        inboundConstraint?.isActive = false
        outboundConstraint?.isActive = true
        // remove avatar view as message is sent by me
        avatarView.isHidden = true
        // bubble will have color so, text color = .white
//        messageContentView.textColor = .white
    }
    
    fileprivate func alignReceivedBubble(_ isStart: Bool, _ model: MessageDomain) {
        // received message will align to the left
        outboundConstraint?.isActive = false
        inboundConstraint?.isActive = true
//        messageContentView.textColor = .black
        // show avatar view if is the last continuous message a friend sent
        avatarView.isHidden = !isStart
        
        if isStart{
            showAvatar(fid: model.sender)
        }
    }
    
    func showAvatar(fid: String){
        interactor?.findFriend(fid: fid, callback: { res, err in
            if let friend = res {
                let url = friend.avatar
                DispatchQueue.main.async {
                    self.avatarView.update(url: url, text: friend.name)
                }
            } 
        })
    }
    func showAvatar(name: String){
        let delay = 200
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(delay), execute: {
            self.avatarView.update(url: nil, text: name)
        })
    }


    
    
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
//        self.bubbleImageView.tintColor = color
    }
    
    // MARK: Setup views
    
    func setupMessageBody(){
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.outboundConstraint =  messageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bubbleHPadding - 6)
        self.inboundConstraint = messageContainerView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: bubbleHPadding)
        self.continuousConstraint = messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: bubbleVPadding)

        let constraints : [NSLayoutConstraint] = [
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bubbleVPadding),
            continuousConstraint,
            outboundConstraint,
            inboundConstraint,
            messageContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: bubbleWidth),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    func setupStatusImage(){
        
        statusImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            statusImage.widthAnchor.constraint(equalToConstant: 15),
            statusImage.heightAnchor.constraint(equalToConstant: 15),
            statusImage.leadingAnchor.constraint(equalTo:  messageContainerView.trailingAnchor, constant: 1),
            statusImage.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        }
    

    func setupTimestamp(){
        
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            timestampLabel.topAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: 2),
            timestampLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor),
            timestampLabel.heightAnchor.constraint(equalToConstant: 13),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        }
    
    func setupAvatarView(){
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            avatarView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: 8),
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
            downloadButton.leadingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: 0),
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


