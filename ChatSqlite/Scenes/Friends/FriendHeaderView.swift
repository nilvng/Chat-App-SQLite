//
//  FriendHeaderView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 15/03/2022.
//

import UIKit

class FriendHeaderView: UITableViewHeaderFooterView {
    static let identifier = "FriendHeaderView"
    private let label : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)

    }
    
    func setTitle(s: String){
        label.text = s
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.sizeToFit()
        label.frame = CGRect(x: 15, y: 0, width: contentView.frame.size.width,
                             height: label.frame.size.height)
    }
}
