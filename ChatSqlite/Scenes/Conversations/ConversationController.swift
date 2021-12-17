//
//  ViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

class ConversationController: UITableViewController {

    var interactor : ConversationInteractor?
    var conversations : [Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
        
        // table
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "convCell")
        
        // navigation
        navigationItem.title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                            action: #selector(addMess))
    }
    
    func setup() {
        let inter = ConversationInteractor()
        inter.presenter = self
        interactor = inter
    }
    
    @objc func addMess(){
        let fController = FriendsController()
        navigationController?.pushViewController(fController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.fetchData()
    }

}

extension ConversationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "convCell") else {
            fatalError()
        }
        
        cell.textLabel?.text = conversations[indexPath.row].title
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = MessengesController()
        controller.configure(conversation: conversations[indexPath.row]){ newMess in
            self.updateLastMessenge(newMess, at: indexPath)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func updateLastMessenge(_ msg : Message, at i : IndexPath){
        
        let cell = tableView.cellForRow(at: i)
        
        cell?.detailTextLabel?.text = msg.content
        // TBD: reorder cell
    }
}

extension ConversationController : ConversationPresenter{
    func presentNewItems(_ item: Conversation) {
        self.conversations.append(item)
        tableView.reloadData()
    }
    
    func presentAllItems(_ items: [Conversation]) {
        self.conversations = items
        tableView.reloadData()
    }
    
    
}
