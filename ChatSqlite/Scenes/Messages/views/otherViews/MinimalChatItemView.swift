//
//  MinimalChatItemView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 06/05/2022.
//

import UIKit

class MinimalChatItemView: UIView {
    var avatarView = AlamoAvatarView(frame: .zero)
    var titleLabel : UILabel = {
        let chatTitleLabel = UILabel()
        chatTitleLabel.font = UIFont.systemFont(ofSize: 19)
        chatTitleLabel.text = "New Friend"
        return chatTitleLabel
    }()
    var stackView : UIStackView = {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        
        view.alignment = .fill
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 10
        return view
    }()
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        stackView.addArrangedSubview(avatarView)
        avatarView.constraint(equalTo: CGSize(width: 45, height: 45))
        avatarView.contentMode = .scaleAspectFill
        stackView.addArrangedSubview(titleLabel)
        self.addSubview(stackView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, avatarUrlString: String?) {
        titleLabel.text = title
        avatarView.update(url: avatarUrlString, text: title)
    }

}
