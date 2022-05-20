//
//  ReferenceView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 06/05/2022.
//

import UIKit

class ReferenceView: UIView {

    var userNameLabel: UILabel!
    var bodyLabel: UILabel!
    var cancelButton : UIButton!
    
    init(){
        super.init(frame: .zero)
        setupUserNameLabel()
        setupBodyLabel()
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(name: String, body: String){
        userNameLabel.text = name
        bodyLabel.text = body
    }
    
    func setupButton(){
        cancelButton = UIButton()
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        self.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    func setupUserNameLabel(){
        userNameLabel = UILabel()
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.addSubview(userNameLabel)
        userNameLabel.addConstraints(top: topAnchor,
                                     leading: leadingAnchor, trailing: trailingAnchor,
                                     leftConstant: 10)
    }
    func setupBodyLabel(){
        bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(bodyLabel)
        bodyLabel.addConstraints(top: userNameLabel.bottomAnchor,
                                 leading: userNameLabel.leadingAnchor,
                                 bottom: bottomAnchor, trailing: trailingAnchor, bottomConstant: 5)
    }
    
    @objc func cancel(){
        self.isHidden = true
    }

}
