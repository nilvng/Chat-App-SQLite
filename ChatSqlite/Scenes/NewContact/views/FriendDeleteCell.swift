//
//  FriendDeleteCell.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/18/21.
//

import UIKit

class FriendDeleteCell: UITableViewCell {
    
    static var identifier : String = "deleteButtonCell"
    
    typealias  deleteAction = () -> Void
    private lazy var button : UIButton = {
        let button              = UIButton()
        button.setTitle("Delete", for: .normal)
        button.backgroundColor  = .red
        button.tintColor        = .white
        return button
    }()
    
    var action : deleteAction?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

    }
    
    func configure(action: @escaping deleteAction){
        self.action = action
    }
    
    override func layoutSubviews() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    @objc func buttonPressed(){
        print("button pressed")
        action?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
