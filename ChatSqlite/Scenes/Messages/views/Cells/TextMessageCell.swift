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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwipe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSwipe(){
        let panGesture = UIPanGestureRecognizer()
        messageContainerView.addGestureRecognizer(panGesture)
        messageContainerView.isUserInteractionEnabled = true
        panGesture.addTarget(self, action: #selector(swipeReply))
    }
    
    var originalPosContainer : CGPoint = .zero
    
    @objc func swipeReply(recognizer: UIPanGestureRecognizer){
        //
        if let swipedView = recognizer.view {
            switch (recognizer.state){
            case .began:
                originalPosContainer = swipedView.center
                break
            case .changed:
                let translation = recognizer.translation(in: swipedView)
                let curX = recognizer.view!.center.x
                let curY = recognizer.view!.center.y
                if insideDraggableArea(swipedView.center) {
                     
                        swipedView.center =  CGPoint(x: curX + translation.x,
                                                     y: curY)
                        recognizer.setTranslation(.zero, in: self)
                    
                }
            case .ended:
                UIView.animate(withDuration: 0.5, delay: 0.02, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveLinear, animations: {
                    recognizer.view?.center = self.originalPosContainer
                }, completion: nil)
            default:
                break
            }
        }
    }
    
    func insideDraggableArea(_ point: CGPoint) -> Bool{
        return point.x < 200
    }
    
    override func configure(with model: MessageDomain,
                            indexPath: IndexPath,
                            isStartMessage isStart: Bool,
                            isEndMessage isEnd: Bool) {
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
