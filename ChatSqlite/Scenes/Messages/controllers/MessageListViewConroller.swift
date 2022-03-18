//
//  MessageDataSource.swift
//  ChatSqlite
//
//  Created by LAP11353 on 31/12/2021.
//

import Foundation
import UIKit
import Alamofire
import Combine

protocol MessageListViewDelegate {
    func messageIsSent(content: String, inTable tableView: UITableView)
    func messageWillDisplay(tableView: UITableView)
    func onConversationChanged(conversation: ConversationDomain)
}

class MessageListViewController : UITableViewController {
    var interactor : MessageListInteractor?
    var parentDelegate : MessageListViewDelegate?
    
    var items : [MessageDomain] = []
    var conversation : ConversationDomain!
    var theme : Theme = .basic
    
    var lastUpdatedOffset : Int = 0
    static var CELL_ID = "messCell"

    
    func configure(friend: FriendDomain){
        self.conversation = ConversationDomain.fromFriend(friend: friend)
        self.parentDelegate?.onConversationChanged(conversation: self.conversation)
    }
    
    func configure(conversation : ConversationDomain){
        self.conversation = conversation
    }
    
    func setItems(_ items: [MessageDomain]){
        self.items = items
        self.items.sort(by: { $0.timestamp > $1.timestamp})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func appendItems(_ items: [MessageDomain]){
        self.items += items
        self.items.sort(by: { $0.timestamp > $1.timestamp})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setBubbleTheme(theme: Theme){
        self.theme = theme
    }
    
    
    func appendNewItem(_ item: MessageDomain){
        DispatchQueue.main.async {
            self.items.insert(item, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            //self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            self.scrollToLastMessage()
        }
    }

    lazy var myTableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        table.alwaysBounceVertical = false
        
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        table.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        table.transform = CGAffineTransform(scaleX: 1, y: -1)
        return table
    }()
    
    override func viewDidLoad() {
        tableView = myTableView
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToLastMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.loadData()
    }
    func scrollToLastMessage(animated: Bool = true){

        guard !items.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            let lastindex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: lastindex, at: .bottom, animated: animated)
        }
    }
}
// MARK: - TableView Delegate
extension MessageListViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        interactor?.loadMore(tableOffset: tableView.contentOffset.y)
        
        // change bubble gradient as scrolling
        if shouldBubbleColorChanged(scrollView: scrollView){
            self.makeBubbleGradient(tableView: tableView)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // update gradient color of visible bubbles
       makeBubbleGradient(tableView: tableView)
    }
}

// MARK: - bubble design
extension MessageListViewController {
    func shouldBubbleColorChanged(scrollView : UIScrollView) -> Bool{
        let ideaRatio = UIScreen.main.bounds.size.height / 17
        let lag : CGFloat = scrollView.isTracking ? 18 : ideaRatio
        let currentPage = (Int) (scrollView.contentOffset.y / lag)

        let res = currentPage != lastUpdatedOffset
        lastUpdatedOffset = currentPage
        return res
    }

func makeBubbleGradient(givenIndices: [IndexPath]? = nil, tableView: UITableView){
   var indices = givenIndices
    DispatchQueue.main.async {
        if indices == nil {
            indices = tableView.indexPathsForVisibleRows
            guard indices != nil else {
                print("no cell!")
                return
            }

        }
        
        for i in indices!{
            guard let cell = tableView.cellForRow(at: i) as? MessageCell else{
                //print("no cell for that index")
                continue
            }
            
            let pos = tableView.rectForRow(at: i)
            let relativePos = tableView.convert(pos, to: tableView.superview)
            
            cell.updateGradient(currentFrame: relativePos, theme: self.theme)
        }
    }
}
    
}

// MARK: - TableView DataSource

extension MessageListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let reverseIndex = indexPath.row
        let message =  items[reverseIndex]
        
        let isLastContinuous = isLastContinuousMess(index: reverseIndex, message: message)
                
        cell.configure(with: message, lastContinuousMess: isLastContinuous)
        if isLastContinuous { cell.showAvatar(name: conversation.title)} // show placeholder is the name of conversation
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
    }
    
    func isLastContinuousMess(index: Int, message: MessageDomain) -> Bool{
        var isLastContinuous = index == 0
        
        if index - 1 >= 0 {
            let laterMessage = items[index - 1]
            isLastContinuous = laterMessage.sender != message.sender
        }
        return isLastContinuous
    }
    
}

// MARK: Presenter
extension MessageListViewController : MessagesPresenter {
    
    func presentMessageStatus(id: String, status: MessageStatus) {
        if let index = items.firstIndex(where: { $0.mid == id}) {
            items[index].status = status
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func presentItems(_ items: [MessageDomain]?, offset: Int) {
        guard let validItems = items, offset >= self.items.count else {
            return
        }
        self.appendItems(validItems)
    }

    
    func presentReceivedItem(_ item: MessageDomain) {
        
        self.appendNewItem(item)

    }
    func presentSentItem(_ item: MessageDomain) {
        
        guard item.sender == UserSettings.shared.getUserID() else {
            presentReceivedItem(item)
            return
        }

//        DispatchQueue.main.async {
            self.appendNewItem(item)
            self.parentDelegate?.messageIsSent(content: item.content, inTable: self.tableView)
//        }
    }
    
    func onFoundConversation(_ c: ConversationDomain){
        
        self.conversation = c
        self.parentDelegate?.onConversationChanged(conversation: c)
    }
}
