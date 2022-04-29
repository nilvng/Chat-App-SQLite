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
import Photos
import AVKit

protocol MessageListViewDelegate : AnyObject{
    func textMessageIsSent(content: String, inTable tableView: UITableView)
    func messageWillDisplay(tableView: UITableView)
    func onConversationChanged(conversation: ConversationDomain)
}

class MessageListViewController : UITableViewController {
    var interactor : MessageListInteractor?
    weak var parentDelegate : MessageListViewDelegate?
    
    var itemsCount : Int = 0
    var dateSections : [DateSection] = []
    
    var conversation : ConversationDomain!
    var theme : Theme = .basic
    
    var lastUpdatedOffset : Int = 0
    static var CELL_ID = "messCell"
    
    struct DateSection {
        var title : String
        var items : [MessageDomain]
    }
    
    
    func configure(friend: FriendDomain){
        self.conversation = ConversationDomain.fromFriend(friend: friend)
        self.parentDelegate?.onConversationChanged(conversation: self.conversation)
    }
    
    func configure(conversation : ConversationDomain){
        self.conversation = conversation
    }
    
    func appendItems(_ items: [MessageDomain]){
        //self.items.sort(by: { $0.timestamp > $1.timestamp})
        
        let newSections = sortByDate(items: items)
        resolveAndMergeSections(newSections: newSections)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func resolveAndMergeSections(newSections: [DateSection]){
        let curN = dateSections.count
       
        if curN > 0 && dateSections[curN-1].title == newSections[0].title {
            dateSections[curN-1].items.append(contentsOf: newSections[0].items)
            for i in 1..<newSections.count{
                dateSections.append(newSections[i])
            }
        } else {
            dateSections.append(contentsOf: newSections)
        }
        
    }
    
    func setBubbleTheme(theme: Theme){
        self.theme = theme
    }
    
    
    func appendNewItem(_ item: MessageDomain){
        let timestampString = item.timestamp.toSimpleDate()
        
        if dateSections.count > 0 {
            let lastSection = dateSections[0]
            
            if lastSection.title == timestampString { // Same date with previous section
                dateSections[0].items.insert(item, at: 0)
                DispatchQueue.main.async {
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                    self.scrollToLastMessage()
                    
                }
                return
            }
        }
        
        let newSection = DateSection(title: timestampString, items: [item])
        dateSections.insert(newSection, at: 0)
        DispatchQueue.main.async {
            self.tableView.insertSections(IndexSet(integer: 0), with: .top)
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
        table.estimatedRowHeight = 250
        table.rowHeight = UITableView.automaticDimension
        table.transform = CGAffineTransform(scaleX: 1, y: -1)
        return table
    }()
    
    override func viewDidLoad() {
        myTableView.register(TextMessageCell.self, forCellReuseIdentifier: TextMessageCell.ID)
        myTableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        myTableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.ID)
        myTableView.register(ImageGridCell.self, forCellReuseIdentifier: ImageGridCell.ID)
        myTableView.register(TimestampHeaderView.self, forHeaderFooterViewReuseIdentifier: TimestampHeaderView.identifier)
        tableView = myTableView

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor?.loadData()
        scrollToLastMessage()
        NotificationCenter.default.addObserver(self, selector: #selector(finishCacheMessageHandler), name: .onFinishCacheImageOfMessage, object: nil)
    }
    
    @objc func finishCacheMessageHandler(noti: Notification){
        guard let m = noti.object as? MessageDomain else{
            return
        }
        
        self.findAndReplace(m: m)
    }
    
    func findAndReplace(m: MessageDomain){
        var foundSectionIndex : Int!
        var foundRowIndex : Int!
        
        for sIndex in 0..<dateSections.count {
            if dateSections[sIndex].title == m.timestamp.toSimpleDate() {
                foundSectionIndex = sIndex
                break
            }
        }
        guard foundSectionIndex != nil else {
            return
            
        }
        for it in 0..<dateSections[foundSectionIndex].items.count {
            if dateSections[foundSectionIndex].items[it].mid == m.mid {
                dateSections[foundSectionIndex].items[it] = m
                foundRowIndex = it
                break
            }
        }
        guard foundRowIndex != nil else {
            return
            
        }
        DispatchQueue.main.async {
            print("row:\(foundRowIndex), section: \(foundSectionIndex)")
            let indexPath = IndexPath(row: foundRowIndex, section: foundSectionIndex)
            if let cell = self.tableView.cellForRow(at: indexPath) as? ImageGridCell{
                cell.reloadData()
            }
            if let cell = self.tableView.cellForRow(at: indexPath) as? ImageCell {
                cell.reloadData()
            }
            
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func scrollToLastMessage(animated: Bool = true){

        guard itemsCount > 0 && tableView.numberOfSections > 0 else {
            return
        }
        DispatchQueue.main.async {
            let lastindex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: lastindex, at: .bottom, animated: animated)
        }
    }
    
    func sortByDate(items: [MessageDomain]) -> [DateSection]{
        let sections = Dictionary(grouping: items, by: { (item) -> DateComponents in
            let date = Calendar.current.dateComponents([.day, .year, .month], from: (item.timestamp))

                return date
        })
        let sortedSections = sections.sorted {
            Calendar.current.date(from: $0.key) ?? Date.distantFuture >
                   Calendar.current.date(from: $1.key) ?? Date.distantFuture
        }
        // map the sorted keys to a struct
        return sortedSections.map{ section in
            let date = Calendar.current.date(from: section.key) ?? Date.distantFuture
            return DateSection(title: date.toSimpleDate(), items: section.value)
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
        return dateSections[section].items.count
    }
    
    fileprivate func getTextCell(_ tableView: UITableView, _ indexPath: IndexPath, _ message: MessageDomain) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let isEndOfContinous = isEndOfContinuousMessages(indexPath: indexPath, message: message)
        let isStartOfContinuous = isStartOfContinuousMessages(indexPath: indexPath, message: message)
        
        cell.configure(with: message,
                       indexPath: indexPath,
                       isStartMessage: isStartOfContinuous,
                       isEndMessage: isEndOfContinous)
        if isStartOfContinuous { cell.showAvatar(name: conversation.title)} // show placeholder is the name of conversation
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : MessageCell!
        
        let message =  dateSections[indexPath.section].items[indexPath.row]
        
        if message.type == .text {
            cell = tableView.dequeueReusableCell(withIdentifier: TextMessageCell.ID, for: indexPath) as? TextMessageCell
        } else if message.type == .image{
            if message.urls.count > 1 || message.mediaPreps?.count ?? 0 > 1 {
                let gridCell = tableView.dequeueReusableCell(withIdentifier: ImageGridCell.ID) as! ImageGridCell
                gridCell.gridCellDelegate = self
                cell = gridCell
            } else {
                let imCell = tableView.dequeueReusableCell(withIdentifier: ImageCell.ID) as! ImageCell
                imCell.delegate = self
                cell = imCell
                }

        }
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)

        let isEndOfContinous = isEndOfContinuousMessages(indexPath: indexPath, message: message)
        let isStartOfContinuous = isStartOfContinuousMessages(indexPath: indexPath, message: message)
        
        cell.configure(with: message,
                       indexPath: indexPath,
                       isStartMessage: isStartOfContinuous,
                       isEndMessage: isEndOfContinous)
        
        if isStartOfContinuous { cell.showAvatar(name: conversation.title)} // show placeholder is the name of conversation
        
        return cell
    }

    
    func isEndOfContinuousMessages(indexPath: IndexPath, message: MessageDomain) -> Bool{
        var laterMessage : MessageDomain
        let sectionItems = dateSections[indexPath.section].items
        var res = true
        let row = indexPath.row
        if row - 1 >= 0 { // last item <> next item
            laterMessage = sectionItems[row - 1]
            res = laterMessage.sender == message.sender
        }
        if row + 1 < sectionItems.count { // last item == previous item
            laterMessage = sectionItems[row + 1]
            res = laterMessage.sender != message.sender && row == 0
        }
        return res

    }
    
    func isStartOfContinuousMessages(indexPath: IndexPath, message: MessageDomain) -> Bool{
        var laterMessage : MessageDomain
        let sectionItems = dateSections[indexPath.section].items
        let row = indexPath.row
        if row - 1 >= 0 { // last item <> next item
            laterMessage = sectionItems[row - 1]
            return laterMessage.sender != message.sender
        }
        if row + 1 < sectionItems.count { // last item == previous item
            laterMessage = sectionItems[row + 1]
            return laterMessage.sender == message.sender || row == 0
        }
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dateSections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimestampHeaderView.identifier) as? TimestampHeaderView else {
            fatalError()
        }
        let curSection = dateSections[section]
        let time = curSection.items[0].timestamp.getTimeString()
        
        let title = "\(curSection.title) at \(time)"
        view.setTitle(s: title)
        view.transform = CGAffineTransform(scaleX: 1, y: -1)
        return view
    }
 
    
}

// MARK: GridCellDelegate
extension MessageListViewController : GridCellDelegate {
    func didSelect(i: Int, of message: MessageDomain) {
                let photoVC = MediaViewController()
                photoVC.configure(i: i, of: message)
                show(photoVC, sender: nil)

    }
    
    
}

extension MessageListViewController : ImageCellDelegate {
    func didTap(_ cell: ImageCell) {
        var message = cell.message
        var index = cell.index
        if cell.message.getPrep(index: cell.index)?.type == .photo{
            let photoVC = MediaViewController()
            
            photoVC.configure(i: cell.index, of: cell.message)
            show(photoVC, sender: nil)
        } else {
            let videoVC = AVPlayerViewController()
            guard let videoURL = MediaWorker.shared.url(index: index!, of: message!,
                            isExist: true) else {return}
            videoVC.player = AVPlayer(url: videoURL)
            show(videoVC, sender:nil)
        }

    }
}

// MARK: Presenter
extension MessageListViewController : MessagesPresenter {

    func presentFFMessageStatus() {
        //
        var stopPoint : Int = 0
//            for index in 0..<itemsCount {
//                if items[index].status != .seen {
//                    items[index].status = .seen
//                } else {
//                    stopPoint = index
//                    break
//                }
//            }
//            let updatedSections = sortByDate(items: items)
//            dateSections = updatedSections
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
    }
    
    func updateARowItem(item: MessageDomain){
        guard dateSections.count > 0 else {
            return
        }
        for sIndex in 0..<dateSections.count {
            var section = dateSections[sIndex]
            if let row = section.items.firstIndex(where: { $0.mid == item.mid}) {
                section.items[row] = item
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: sIndex)], with: .automatic)
                }
            }
        }
    }
    
    
    func presentMessageStatus(id: String, status: MessageStatus) {

//        if let index = items.firstIndex(where: { $0.mid == id}) {
//            items[index].status = status
//            updateARowItem(item: items[index])
//
//        }
    }
    
    func presentItems(_ items: [MessageDomain]?, offset: Int) {
        guard let validItems = items, offset >= self.itemsCount else {
            return
        }
        itemsCount += validItems.count
        self.appendItems(validItems)
    }

    
    func presentReceivedItem(_ item: MessageDomain) {
        
        self.appendNewItem(item)
        interactor?.sendSeenStatus()

    }
    func presentSentItem(_ item: MessageDomain) {
        
        guard item.sender == UserSettings.shared.getUserID() else {
            presentReceivedItem(item)
            return
        }
            self.appendNewItem(item)
        
        if item.type == .text {
            self.parentDelegate?.textMessageIsSent(content: item.content, inTable: self.tableView)
        }
    }
    
    func onFoundConversation(_ c: ConversationDomain){
        
        self.conversation = c
        self.parentDelegate?.onConversationChanged(conversation: c)
    }
}
