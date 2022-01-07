//
//  ConversationCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationCell : UITableViewCell {
    
    // MARK: Properties
    
    static let identifier  = "ConversationCell"
        
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.textAlignment = .left
        return label
    }()
    private let lastMessageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    private let timestampLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.tintColor = .gray
        label.textAlignment = .left
        return label

    }()
    private let thumbnail : AvatarView = {
        let image = AvatarView(frame: .zero)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
    }()

    // MARK: Configuration
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(thumbnail)
        contentView.addSubview(separatorLine)

    }
    
    func configure (model : ConversationDomain){
        
        
        titleLabel.text = model.title
        
        thumbnail.update(url: model.thumbnail, text: model.title)
        
        lastMessageLabel.text = model.lastMsg
        timestampLabel.text = model.timestamp.toTimestampString()
    }

    // MARK: AutoLayout setups
    
    private var verticalPadding : CGFloat = 5
    private var horizontalPadding : CGFloat = 10

    override func layoutSubviews() {
        setupThumbnail()
        setupTitleLabel()
        setupLastMessageLabel()
        setupTimestampLabel()
        setupSeparatorLine()
    }
    
    
    
    func setupThumbnail() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        
        let height : CGFloat = 67
        let width = height
        
        let constraints : [NSLayoutConstraint] = [
            thumbnail.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            thumbnail.widthAnchor.constraint(equalToConstant: width),
            thumbnail.heightAnchor.constraint(equalToConstant: height)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            titleLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor,constant: -14),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 14)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupLastMessageLabel() {
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            lastMessageLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor,constant:11),
            lastMessageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -15)
        ]
        lastMessageLabel.setContentHuggingPriority(.init(250), for: .vertical)
        lastMessageLabel.setContentCompressionResistancePriority(.init(249), for: .vertical)
        lastMessageLabel.setContentCompressionResistancePriority(.init(249), for: .horizontal)

        NSLayoutConstraint.activate(constraints)
    }

    func setupTimestampLabel() {
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            timestampLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ]
        timestampLabel.setContentCompressionResistancePriority(.init(252), for: .horizontal)

        NSLayoutConstraint.activate(constraints)
    }

    func setupSeparatorLine(){
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



