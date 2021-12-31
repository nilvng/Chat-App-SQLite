//
//  MessengeController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import UIKit

protocol MessagesDislayLogic {
    func fetchData(friend: FriendDomain)
    func fetchData(conversation: ConversationDomain)
    func onScroll(tableOffset: CGFloat)
    func sendMessage(content: String, newConv: Bool)
}

class MessagesController: UITableViewController {

    typealias lastMsgAction = (MessageDomain) -> Void
    
    var updateLastMsgAction : lastMsgAction?
    
    var interactor : MessagesDislayLogic?
    var dataSource = MessageDataSource()
    
    var theme : String? = "basic"
    var conversation : ConversationDomain?
    
    
    var isNew : Bool = false
    
    init(){
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(friend: FriendDomain){
        interactor?.fetchData(friend: friend)
        self.conversation = ConversationDomain.fromFriend(friend: friend)
    }
    
    func configure(conversation : ConversationDomain, action : lastMsgAction? = nil){
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

        navigationItem.title = conversation?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addMess))
        tableView.dataSource = dataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let c = conversation else {return}
        interactor?.fetchData(conversation: c)
    }

    @objc func addMess(){
        let text = ["Random talk", "see you", "salute"].randomElement()!
        
        interactor?.sendMessage(content: text, newConv: isNew)

        if !isNew {
            print("old chat")
        } else {
            print("new chat")
            isNew = false
        }

    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.onScroll(tableOffset: tableView.contentOffset.y)
    }

}

extension MessagesController : MessagesPresenter {
    
    func presentAllItems(_ items: [MessageDomain]?) {
        if items == nil {
            isNew = true
            return
        }
        
        dataSource.appendItems(items!)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func presentNewItem(_ item: MessageDomain) {
        
        dataSource.appendItems([item])
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        
        }
    }
    
    func loadConversation(_ c: ConversationDomain, isNew : Bool){
        DispatchQueue.main.async {
        self.isNew = isNew
        self.conversation = c
        }
    }
    
    
}
