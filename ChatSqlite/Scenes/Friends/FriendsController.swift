//
//  FriendsController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

protocol FriendsDisplayLogic {
    func fetchData()
    func addItem(_ item: FriendDomain)
}

class FriendsController: UITableViewController {

    var interactor : FriendsDisplayLogic?
    var dataSource  = FriendDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        navigationItem.title = "Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonPressed))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FriendDataSource.CELL_ID)

    }
    func setup() {
        let inter = FriendInteractor(store: FriendSQLiteStore())
        inter.presenter = self
        interactor = inter
    }

    @objc func addButtonPressed(){
        let names = ["Meme", "Bingo", "WRM"]
        let friend = FriendDomain(avatar: "hello", id: UUID().uuidString, phoneNumber: "1234", name: names.randomElement()!)
        
        presentNewItems(friend)
        interactor?.addItem(friend)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatController = MessagesController()
        let friend = dataSource.getItem(ip: indexPath)

        chatController.configure(friend: friend)
        
        navigationController?.pushViewController(chatController, animated: true)
    }
    

    // MARK: - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.fetchData()
    }
    

}

extension FriendsController : FriendPresenter {
    func presentNewItems(_ item: FriendDomain) {
        dataSource.appendItems([item])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
        
    }
    
    func presentItems(_ items: [FriendDomain]) {
        dataSource.appendItems(items)
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
        
    }
    
    
    
}
