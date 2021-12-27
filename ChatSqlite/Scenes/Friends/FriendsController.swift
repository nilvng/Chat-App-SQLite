//
//  FriendsController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

protocol FriendsDisplayLogic {
    func fetchData()
    func addItem(_ item: FriendsModel)
}

class FriendsController: UITableViewController {

    var interactor : FriendsDisplayLogic?
    var friends : [FriendsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        navigationItem.title = "Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonPressed))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")

    }
    func setup() {
        let inter = FriendInteractor(store: FriendSQLiteStore())
        inter.presenter = self
        interactor = inter
    }

    @objc func addButtonPressed(){
        let names = ["Meme", "Bingo", "WRM"]
        let friend = FriendsModel(avatar: "hello", id: UUID().uuidString, phoneNumber: "1234", name: names.randomElement()!)
        interactor?.addItem(friend)
    }
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = friends[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatController = MessagesController()
        let friend = friends[indexPath.row]

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
    func presentNewItems(_ item: FriendsModel) {
        self.friends.append(item)
        tableView.reloadData()
    }
    
    func presentItems(_ items: [FriendsModel]) {
        self.friends = items
        tableView.reloadData()
    }
    
    
    
}
