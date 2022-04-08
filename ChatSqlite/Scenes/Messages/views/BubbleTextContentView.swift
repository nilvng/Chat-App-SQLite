//
//  TextCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 29/03/2022.
//

import UIKit

class BubbleContentView : UIView {
    
    func styleSent(){}
    func styleReceived(){}
    func styleDownload(){}
    
}

class BubbleTextContentView : UIView {


    var bubbleImageView = UIImageView()
    let textLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.backgroundColor = .clear
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        super.addSubview(bubbleImageView)
        self.addSubview(textLabel)
        setupBubble()
        setupLabel()
    }
    func styleDownloadbleBubble(content: String = ""){
        // show download button next to content message
        let size : CGFloat = 16
        textLabel.font = UIFont.boldSystemFont(ofSize: size)
        textLabel.text = content
        
    }
    
    var bubbleVPadding : CGFloat = BubbleConstant.vPadding
    var bubbleHPadding : CGFloat = BubbleConstant.hPadding
    
    func setupBubble(){
            
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            bubbleImageView.topAnchor.constraint(equalTo: textLabel.topAnchor, constant: -bubbleVPadding + BubbleConstant.contentVPadding),
            bubbleImageView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -bubbleHPadding + BubbleConstant.contentHPadding),
            bubbleImageView.bottomAnchor.constraint(equalTo:  textLabel.bottomAnchor, constant: bubbleVPadding - BubbleConstant.contentVPadding),
            bubbleImageView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: bubbleHPadding - BubbleConstant.contentHPadding),
        ]
        
        NSLayoutConstraint.activate(constraints)
    
    }
    func setupLabel(){
        textLabel.anchor(top: self.topAnchor,
                                       leading: self.leadingAnchor,
                                       bottom: self.bottomAnchor,
                                       trailing: self.trailingAnchor)
    }
    
    func configure(with text: String, im: UIImage){
        textLabel.text = text
        bubbleImageView.image = im
    }
    
    func setTextColor(_ color: UIColor){
        textLabel.textColor = color
    }
    
    func setBubbleColor(_ color: UIColor?){
        bubbleImageView.tintColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
