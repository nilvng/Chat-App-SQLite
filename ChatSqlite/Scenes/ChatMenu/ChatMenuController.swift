//
//  MessagesMenuViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/17/21.
//

import UIKit

class ChatMenuController : UIViewController{
        
    var conversation : ConversationDomain!
    var service : ConversationService!
    var msgService : MessageService?
    
    let deleteButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    func setup(){
        service = ConversationStoreProxy.shared
        msgService = MessageWorkerManager.shared.get(cid: conversation.id)
    }
    
    fileprivate func setupDeleteButton() {
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.setTitle("Delete Conversation", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)

    }
    
    fileprivate func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
    }

    @objc func deleteButtonPressed() {
        performDeleteItem()
        navigationController?.popViewController(animated: true)
    }
    
    func performDeleteItem(){
        let id = conversation.id
        
        // delete in Conv table
        service.deleteItem(id: id, completionHandler: { err in
            print(err?.localizedDescription ?? "successfully delete conv : \(id)")
        })
        
        // delete in Msg table
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Chat Info"
        setupTitleLabel()
        setupDeleteButton()
    }
    
    func configure(_ model: ConversationDomain){
        titleLabel.text = model.title
        self.conversation = model
        setup()
    }
}
