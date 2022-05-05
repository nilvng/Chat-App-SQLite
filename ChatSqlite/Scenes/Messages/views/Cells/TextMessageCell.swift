//
//  TextMessageCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 08/04/2022.
//

import UIKit
class TextMessageCell : MessageCell {
    
    static let ID = "TextMessageCell"
    
    lazy var textMessageView : BubbleTextContentView = {
        let view = BubbleTextContentView()
        messageContainerView.addSubview(view)
        view.addConstraints(top: messageContainerView.topAnchor, leading: messageContainerView.leadingAnchor, bottom: messageContainerView.bottomAnchor, trailing: messageContainerView.trailingAnchor)
        return view
    }()
//    var incomingBubbleConfig : BackgroundConfig = {
//        let config = BackgroundConfig()
//        config.color = UIColor.trueLightGray
//        config.corner = [.topRight, .bottomRight, .topLeft]
//        config.radius = 14
//        return config
//    }()
//
//    var outgoingBubbleConfig : BackgroundConfig = {
//        let config = BackgroundConfig()
//        config.color = .none
//        config.corner = [.topLeft, .bottomLeft, .topRight]
//        config.radius = 14
//        return config
//    }()
    
    override func configure(with model: MessageDomain, indexPath: IndexPath, isStartMessage isStart: Bool, isEndMessage isEnd: Bool) {
        let isReceived = isReceived(sender: model.sender)
        let config = isReceived ? incomingBubbleConfig : outgoingBubbleConfig
        let im = BackgroundFactory.shared.getBackground(config: config)
        
        textMessageView.configure(with: model.content, im: im)
        let textColor : UIColor = isReceived ? .black : .white
        textMessageView.setTextColor(textColor)
        super.configure(with: model, indexPath: indexPath, isStartMessage: isStart, isEndMessage: isEnd)
    }
    
    override func styleDownloadbleBubble(isIt: Bool, content: String = "", isReceived: Bool = false) {
        
    }
    
    override func updateGradient(currentFrame: CGRect, theme: Theme) {
        
        guard !isReceived(sender: message.sender) else {
            return
        }
        let normalizedY = currentFrame.maxY
        
        if normalizedY < 0 {
            print(normalizedY)
            return
        }

        let color = theme.gradientImage.getPixelColor(pos: CGPoint(x:10 , y: normalizedY))
        textMessageView.setBubbleColor(color)
    }
    
}
