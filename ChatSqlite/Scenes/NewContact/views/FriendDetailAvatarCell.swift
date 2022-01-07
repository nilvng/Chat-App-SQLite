//
//  FriendDetailHeader.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit

class FriendDetailAvatarCell: UITableViewCell {
    static let identifier = "AvatarCell"
    
    private let avatarView : AvatarView = {
        let image = AvatarView(frame: .zero)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private var nameLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(avatarView)
        addSubview(nameLabel)
        backgroundColor = .systemTeal
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
        nameLabel.text = fullname
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupAvatarView()
        setupNameLabel()
    }
    private func setupAvatarView(){
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let avatarConstraints = [
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100)
        ]
        NSLayoutConstraint.activate(avatarConstraints)
    }
    
    private func setupNameLabel(){
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 10).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true

    }
}

