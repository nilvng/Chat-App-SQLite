//
//  SearchContactCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/4/21.
//

import UIKit

class SearchContactCell : UITableViewCell {
    
    // MARK: Properties
    
    static let identifier  = "SearchContactCell"
        
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    let avatarView : AvatarView = {
        let image = AvatarView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(avatarView)
        setupThumbnail()
        setupTitleLabel()
    }
    
    func configure (friend : FriendDomain){
        titleLabel.text = friend.name
        avatarView.backgroundColor = .clear
        avatarView.update(url: friend.avatar, text: friend.name)
    }
    func configure (option : OtherOptions ){
        titleLabel.text = option.getKeyword()
        avatarView.backgroundColor = .babyBlue
        avatarView.image = option.image
    }
    
    // MARK: Design Cell
    
    private var verticalPadding : CGFloat = 7
    private var horizontalPadding : CGFloat = 10
    
    func setupThumbnail() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        let width : CGFloat = 50
        let height : CGFloat = 50
        
        let constraints : [NSLayoutConstraint] = [
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            avatarView.widthAnchor.constraint(equalToConstant: width),
            avatarView.heightAnchor.constraint(equalToConstant: height)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            titleLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor,constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



