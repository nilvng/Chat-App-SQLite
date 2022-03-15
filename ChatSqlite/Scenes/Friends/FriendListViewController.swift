//
//  FriendsController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

protocol FriendDBMediator {
    func fetchData()
    func addItem(_ item: FriendDomain)
}

class FriendListViewController: UIViewController {

    var router : FriendRouter?
    var mediator : FriendDBMediator?
    var dataSource  = FriendDataSource()
    
    var currentSearchText : String = ""
    lazy var searchField : UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search..."
        return bar
    }()
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.rowHeight = 58
        tv.separatorStyle = .none
//        tv.sectionIndexMinimumDisplayRowCount = 100
        tv.sectionFooterHeight = 0
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .zaloBlue
        setupInteractor()
        setupRouter()
        setupSearchField()
        setupTableView()
        
        navigationItem.title = "Friends"

    }
    
    func setupSearchField(){
        
        view.addSubview(searchField)
        searchField.delegate = self
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchField.heightAnchor.constraint(equalToConstant: 40)
                                        ])

        searchField.searchTextField.backgroundColor = .white
    }
    
    
    func setupInteractor() {
        let inter = FriendMediator()
        inter.presenter = self
        mediator = inter
        
    }
    func setupRouter() {
        let router = FriendRouter()
        router.viewController = self
        self.router = router
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)
        tableView.register(FriendHeaderView.self, forHeaderFooterViewReuseIdentifier: FriendHeaderView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 7).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }

    // MARK: - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediator?.fetchData()
    }
    
    func newContactCallback(item: FriendDomain) {
        self.mediator?.addItem(item)
    }

    
    func promptForAnswer(){
        let ac = UIAlertController(title: "Your Friend ID", message: "please?", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { [unowned ac] _ in
            guard let answer = ac.textFields![0].text, answer != "" else {
                return
            }
            self.router?.toChatView(for: FriendDomain(id: answer, phoneNumber: "xxx", name: answer, avatar: nil))
        })
        ac.addAction(submitAction)
        present(ac,animated: true)
    }
}

// MARK: TableDelegate
extension FriendListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let option = dataSource.getItem(ip: indexPath)
        
        // Click Friend
        if let friend = option as? FriendDomain {
            router?.toChatView(for: friend)
        } else {
            // Click on option
            if let other = option as? OtherOptions, other.title == .newContact{
            router?.toNewContactView(callback: newContactCallback)
            } else {
                promptForAnswer()
            }
            
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendHeaderView.identifier) as! FriendHeaderView
        header.setTitle(s: dataSource.sections[section].letter ?? "Others")
        return header
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return .leastNormalMagnitude
//    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

}

// MARK: Presenter
extension FriendListViewController : FriendPresenter {
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

//MARK: SearchBarDelegate
extension FriendListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            dataSource.clearSearch()
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let originalText = searchBar.searchTextField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: text)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("search \(cleanText)")
            // only update when it truly changes
            if cleanText != currentSearchText{
                filterItemForSearchKey(cleanText)
            }
        }
        return true
    }
    
    
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
        if key == ""{
            dataSource.clearSearch()
        } else{
            dataSource.filterItemBy(key: key)
        }
        tableView.reloadData()
  }
}

