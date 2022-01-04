//
//  MessageCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessageCell: UITableViewCell {

    lazy var friendSerivce : FriendService = FriendStoreProxy.shared
    var message : MessageDomain?
    static let identifier = "MessageCell"
    var inboundConstraint : NSLayoutConstraint!
    var outboundConstraint : NSLayoutConstraint!
    var continuousConstraint : NSLayoutConstraint!

    
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
        let view = AvatarView(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
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
        
        }
    
    // MARK: Configuration
    func configure(with model: MessageDomain, lastContinuousMess: Bool = false){
        
        backgroundView = .none
        backgroundColor = .clear

        message = model
        messageBodyLabel.text = model.content

        // align bubble based on whether the sender is the user themselves
    
        if model.sender == "1" {
            // get bubble
           bubbleImageView.image = BackgroundFactory.shared.getBackground(config: outgoingBubbleConfig)
            // sent message will align to the right
            inboundConstraint?.isActive = false
            outboundConstraint?.isActive = true
            // remove avatar view as message is sent by me
            avatarView.isHidden = true
            // bubble will have color so, text color = .white
            messageBodyLabel.textColor = .white
        } else {
            // get the bubble image
            bubbleImageView.image = BackgroundFactory.shared.getBackground(config: incomingBubbleConfig)
            // received message will align to the left
            outboundConstraint?.isActive = false
            inboundConstraint?.isActive = true
            messageBodyLabel.textColor = .black
            // show avatar view if is the last continuous message a friend sent
            avatarView.isHidden = !lastContinuousMess
            print("Show avatar")
            
            if lastContinuousMess{
                showAvatar(fid: model.sender)
            }
        }
            // continuous message would be closer to each other
            continuousConstraint.constant = !lastContinuousMess ? -bubbleVPadding + 4 : -bubbleVPadding
    }
    
    func showAvatar(fid: String){
        friendSerivce.fetchItemWithId(fid, completionHandler: { res, err in
            if let friend = res {
                let url = friend.avatar
                DispatchQueue.main.async {
                    self.avatarView.update(url: url, text: friend.name)
                }
            }
        })


    }
    var bubbleVPadding : CGFloat = BubbleConstant.vPadding
    var bubbleHPadding : CGFloat = BubbleConstant.hPadding

    
    
    func updateGradient(currentFrame: CGRect, theme: Theme){
        
        guard message?.sender == "1" else {
            return
        }
        let normalizedY = currentFrame.maxY
        
        if normalizedY < 0 {
            print(normalizedY)
            return
        }

        let color = theme.gradientImage.getPixelColor(pos: CGPoint(x:100 , y: normalizedY))
        self.bubbleImageView.tintColor = color
    }
    
    
    func setupMessageBody(){
        messageBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.outboundConstraint =  messageBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bubbleHPadding)
        self.inboundConstraint = messageBodyLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: bubbleHPadding)
        self.continuousConstraint = messageBodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bubbleVPadding)

        let constraints : [NSLayoutConstraint] = [
            messageBodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: bubbleVPadding),
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
    
    func setupTimestampLabel(){
        contentView.addSubview(timestampLabel)
        timestampLabel.translatesAutoresizingMaskIntoConstraints  = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
