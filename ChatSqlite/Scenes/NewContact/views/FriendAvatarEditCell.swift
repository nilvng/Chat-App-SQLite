//
//  FriendDetailHeader.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

class FriendAvatarEditCell: UITableViewCell {
    static let identifier = "AvatarEditCell"
    
    private let avatarView : AvatarView = {
        let image = AvatarView(frame: .zero)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(avatarView)
        backgroundColor = .systemGray5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(avatar avatarString: String?, fullname: String){
        if let avatar = avatarString{
            avatarView.update(url: avatar, text: fullname)
        } else {
            avatarView.usePlaceholderAvatar(with: fullname)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupAvatarView()
    }
    private func setupAvatarView(){
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let avatarConstraints = [
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100)
        ]
        NSLayoutConstraint.activate(avatarConstraints)
    }
    
}

