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
    var dataSource  = ConversationDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
        
        // table
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: ConversationDataSource.CELL_ID)
        
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
        
        tableView.dataSource = dataSource
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

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = MessagesController()
        let c = dataSource.getItem(ip: indexPath)
        controller.configure(conversation: c){ newMess in
            self.dataSource.updateLastMessenge(newMess, at: indexPath)
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.onScroll(tableOffset: tableView.contentOffset.y)
    }
    

    
}

extension ConversationController : ConversationPresenter{
    func presentNewItems(_ item: ConversationDomain) {
        
        print("present new conv tbd")
        //self.dataSource.appendItems([item])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
    }
    
    func presentAllItems(_ items: [ConversationDomain]?) {
        
        if items == nil {
            return
        }
        
        self.dataSource.loadItems(items!)
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
    }
    
}
