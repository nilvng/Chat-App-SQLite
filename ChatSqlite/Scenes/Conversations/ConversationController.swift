//
//  ViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

protocol ConversationsDisplayLogic {
    func fetchData()
    func addItem(_ conversation : ConversationDomain)
    func onScroll(tableOffset: CGFloat)
}

class ConversationController: UITableViewController {

    var interactor : ConversationsDisplayLogic?
    var conversations : [ConversationDomain] = []
    var cellId = "convCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
        
        // table
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellId)
        
        // navigation
        navigationItem.title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                            action: #selector(addButtonPressed))
    }
    
    func setup() {
        let service = ConversationStoreProxy.shared
        let inter = ConversationInteractor(store: service)
        inter.presenter = self
        interactor = inter
    }
    
    @objc func addButtonPressed(){
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SubtitleCell else {
            fatalError()
        }
                
        cell.textLabel?.text = conversations[indexPath.row].title
        cell.detailTextLabel?.text = conversations[indexPath.row].lastMsg
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = MessagesController()
        
        controller.configure(conversation: conversations[indexPath.row]){ newMess in
            self.updateLastMessenge(newMess, at: indexPath)
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.onScroll(tableOffset: tableView.contentOffset.y)
    }
    
    func updateLastMessenge(_ msg : MessageDomain, at i : IndexPath){
        var c = conversations[i.row]
        c.lastMsg = msg.content
        c.timestamp = msg.timestamp
        conversations[i.row] = c
    }
    
    func searchRowInsert(timestamp : Date) -> Int{
        var l = 0
        var r = conversations.count
        var res = 0
        while ( l <= r){
            let mid = (l + r) / 2
            if conversations[mid].timestamp <= timestamp {
                l = mid + 1
            } else {
                res = mid
                r = mid - 1
            }
        }
        return res
    }
}

extension ConversationController : ConversationPresenter{
    func presentNewItems(_ item: ConversationDomain) {
        
        self.conversations.append(item)
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
    }
    
    func presentAllItems(_ items: [ConversationDomain]?) {
        
        if items == nil {
            return
        }
        
        self.conversations = items!
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
    }
    
}
