//
//  MessengeController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import UIKit

class MessagesController: UITableViewController {

    typealias lastMsgAction = (Message) -> Void
    
    var updateLastMsgAction : lastMsgAction?
    
    var interactor : MessagesInteractor?
    
    var items : [Message] = []
    var conversation : ConversationsModel?
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
    
    func configure(conversation : ConversationsModel, action : lastMsgAction? = nil){
        updateLastMsgAction = action
        self.conversation = conversation
    }
    
    func setup(){
        let inter = MessagesInteractor()
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
        guard let c = conversation else {return}
        interactor?.fetchData(conversation: c)
    }

    @objc func addMess(){
        let text = ["Random talk", "see you", "salute"].randomElement()!
        if let _ = conversation {
            print("old chat")

            interactor?.sendMessenge(content: text, newConv: false)

        } else {

            interactor?.sendMessenge(content: text, newConv: isNew)
            isNew = false
        }

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

extension MessagesController : MessagesPresenter {
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