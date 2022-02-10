//
//  ConversationListView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 09/02/2022.
//

import UIKit

protocol ConversationListViewDelegate{
    func viewBeginDragging(scrollView: UIScrollView)
}

class ConversationListViewController: UITableViewController {
    // MARK: - variables
    var items : [ConversationDomain] = []
    var interactor : ConversationListInteractor?
    var delegate : ConversationListViewDelegate?
    
    // MARK: - methods
    func setItems(_ items: [ConversationDomain]){
        self.items = items
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reloadData(){
        interactor?.loadData()
    }
    
    func filterBy(key: String){
        print("filtering...\(key)")
        guard items.count > 0 else {
            return
        }
        
        let filteredItems = items.filter({ item in
            return item.title.lowercased().contains(key.lowercased())
        })
        self.setItems(filteredItems)
        
        // call Interactor to actually filter data
        interactor?.filterBy(key: key)
    }
    
    // MARK: Setups
    func setupMyTableView(){
        let table = UITableView()
        table.separatorStyle = .none
        table.rowHeight = 86
        tableView = table
    }

    // MARK: Navigation
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMyTableView()
        setupLongPressGesture()
        
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.loadData()
    }

}

extension ConversationListViewController {

    // MARK: - Table view data source
    func getItem(at index: IndexPath) -> ConversationDomain{
        return items[index.row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as? ConversationCell else { fatalError("Wrong cell") }

        // Configure the cell...
        cell.configure(model: items[indexPath.row])
        
        
        return cell
    }

}
// MARK: - Table view  delegate
extension ConversationListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let c = self.getItem(at: indexPath)
        AppRouter.shared.toChatPage(ofConversation: c)

    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.loadMoreData(tableOffset: scrollView.contentOffset.y)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.viewBeginDragging(scrollView: scrollView)
    }

}

// MARK: Presenter
extension ConversationListViewController : ConversationPresenter{
    
    func presentFilteredItems(_ items: [ConversationDomain]?) {
        // #warning: append to current result if it's different from given items
        
        if items != nil && self.items != items! {
            self.setItems(items!)
        }
    }
    
    func presentNewItems(_ item: ConversationDomain) {
        fatalError()
    }
    
    func presentDeleteItem(_ item: ConversationDomain, at index: IndexPath) {
        
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [index], with: .automatic)
        }
    }
    
    func presentAllItems(_ items: [ConversationDomain]?) {
        if items == nil {
            return
        }
        self.setItems(items!)
    }
    
}
// MARK: show Config Menu Controller
extension ConversationListViewController : UIGestureRecognizerDelegate{
    func setupLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5 // 1 second press
        longPress.delegate = self
        tableView.addGestureRecognizer(longPress)
        
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print("Long press row: \(indexPath.row)")
                let configView = ConvConfigController()
                let itemToConfig = self.getItem(at: indexPath)
                configView.configure {
                    self.interactor?.deleteConversation(item: itemToConfig, indexPath: indexPath)
                }
                configView.modalPresentationStyle = UIModalPresentationStyle.custom
                configView.transitioningDelegate = self
                self.present(configView, animated: true)
            }
        }
    }
}

extension ConversationListViewController : UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}
