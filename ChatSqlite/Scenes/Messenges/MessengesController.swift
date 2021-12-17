//
//  MessengeController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import UIKit

class MessengesController: UITableViewController {

    typealias lastMsgAction = (Message) -> Void
    
    var updateLastMsgAction : lastMsgAction?
    
    var interactor : MessengesInteractor?
    
    var items : [Message] = []
    var conversation : Conversation?
    var friend : Friend?
    
    var isNew : Bool = false
    
    init(){
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(friend: Friend){
        interactor?.fetchData(friend: friend)
        self.friend = friend
    }
    
    func configure(conversation : Conversation, action : lastMsgAction? = nil){
        interactor?.fetchData(conversation: conversation)
        updateLastMsgAction = action
        self.conversation = conversation
    }
    
    func setup(){
        let inter = MessengesInteractor()
        inter.presenter = self
        interactor = inter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Messenges"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addMess))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func addMess(){
        let text = ["Random talk", "see you", "salute"].randomElement()!
        var mess : Message
        if let c = conversation {
            mess = MessengeSQLite(conversationId: c.id, content: text, type: .text, timestamp: Date(), sender: "1") // user's id is 1
            interactor?.sendMessenge(mess, newConv: false)

        } else {
            mess = MessengeSQLite(conversationId: "", content: text, type: .text, timestamp: Date(), sender: "1") // user's id is 1
            interactor?.sendMessenge(mess, newConv: isNew)
            isNew = false
        }

        updateLastMsgAction?(mess)
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = items[indexPath.row].content

        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.onScroll(tableOffset: tableView.contentOffset.y)
    }

}

extension MessengesController : MessengesPresenter {
    func presentAllItems(_ items: [Message]?) {
        if items == nil {
            isNew = true
            return
        }
        self.items += items!
        tableView.reloadData()
    }
    
    func presentNewItem(_ item: Message) {
        self.items.append(item)
        tableView.reloadData()
    }
    
    
}
