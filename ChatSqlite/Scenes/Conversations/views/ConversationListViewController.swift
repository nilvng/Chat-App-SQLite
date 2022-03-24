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
    var ogItems : [ConversationDomain]?
    var visible : Bool = false
    
    var interactor : ConversationListInteractor?
    var router : HomeRouter?
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
    
    func clearFilter(){
        if ogItems != nil {
            self.setItems(ogItems!)
        }
        ogItems = nil

        // may need to call interactor to reload
    }
    
    func filterBy(key: String){
        print("filtering...\(key)")
        
        guard items.count > 0 else {
            return
        }
        
        if ogItems == nil {
            ogItems = items
        }
        
        let filteredItems = ogItems!.filter({ item in
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
        visible = true
        interactor?.loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
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
        interactor?.selectConversation(c)
        router?.showChats(for: c)

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
    
    func presentUpdatedItem(_ item: ConversationDomain) {
        guard visible else {
            return
        }
        if let index = self.items.firstIndex(where: {$0.id == item.id}){
            
            items[index] = item
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            
        }else {
            print("\(self) Update row of Conv that not exist")
        }

    }
    
    func insertNewRow(){
        guard visible else {
            return
        }
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    func presentUpsertedItem(item: ConversationDomain) {
        guard visible else {
            return
        }
        if let index = self.items.firstIndex(where: {$0.id == item.id}){
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                for i in (1...index+1).reversed(){
                    self.items[i] = self.items[i-1]
                }
                self.items[0] = item
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        } else {
            self.items.append(item)
            self.insertNewRow()
        }
    }
    
    func presentNewItem(_ item: ConversationDomain) {
        guard visible else {
            return
        }
        self.items.append(item)
        self.items.sort(by: {$0.timestamp > $1.timestamp})
        self.insertNewRow()
    }
    
    
    func presentFilteredItems(_ items: [ConversationDomain]?) {
        // #warning: append to current result if it's different from given items
        
        //presentAllItems(items)
    }
    
    func presentMoreItems(_ items: [ConversationDomain]) {
        guard visible else {
            return
        }
        self.items.append(contentsOf: items)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func presentDeleteItem(_ item: ConversationDomain, at index: IndexPath) {
        guard visible else {
            return
        }
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [index], with: .automatic)
        }
    }
    
    func presentAllItems(_ items: [ConversationDomain]?) {
        if items == nil{
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
