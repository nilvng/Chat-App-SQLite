//
//  TimestampHeaderView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 19/03/2022.
//

import UIKit

class TimestampHeaderView : UITableViewHeaderFooterView {
    static let identifier = "TimestampHeaderView"
    private let label : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 13)
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
        let centerStartingX = contentView.frame.midX - (label.frame.size.width / 2)
        label.frame = CGRect(x: centerStartingX, y: 0, width: contentView.frame.size.width,
                             height: label.frame.size.height)
    }
}
