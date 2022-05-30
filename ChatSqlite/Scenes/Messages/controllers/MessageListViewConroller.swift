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
    func messageDidReply(_ msg: MessageDomain)
}

class MessageListViewController : UITableViewController {
    weak var router : ChatRouter?
    var interactor : MessageListInteractor?
    weak var parentDelegate : MessageListViewDelegate?
    
    var itemsCount : Int = 0
    var dateSections : [DateSection] = []
    
    var currentReference : MessageDomain?
    var conversation : ConversationDomain!
    var theme : Theme = .basic
    
    var lastUpdatedOffset : Int = 0
    var animatableView : UIView?
    var sourceSnapshot : UIView?
    var selectedCell : UIView?
    var shouldRemoveAnimatable : Bool = false
    
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
        guard newSections.count > 0 else{
            return
        }
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
        if shouldRemoveAnimatable, let animView = animatableView, let cellRect = rectSelectedCell() {
            UIView.animate(withDuration: 1, animations: {
                animView.frame = cellRect
            }, completion: { [weak self] _ in
                animView.removeFromSuperview()
                self?.shouldRemoveAnimatable = false
            })
        }
        
    }
    
    func reloadMessageCell(m: MessageDomain){

        guard let indexPath = getIndexPath(of: m) else{
            return
        }
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? ImageGridCell{
                cell.reloadData()
            }
            if let cell = self.tableView.cellForRow(at: indexPath) as? ImageCell {
                cell.reloadData()
            }
            
        }

    }
    
    func getIndexPath(of m: MessageDomain) -> IndexPath?{
        var foundSectionIndex : Int!
        var foundRowIndex : Int!
        
        for sIndex in 0..<dateSections.count {
            if dateSections[sIndex].title == m.timestamp.toSimpleDate() {
                foundSectionIndex = sIndex
                break
            }
        }
        guard foundSectionIndex != nil else {
            return nil
            
        }
        for it in 0..<dateSections[foundSectionIndex].items.count {
            if dateSections[foundSectionIndex].items[it].mid == m.mid {
                dateSections[foundSectionIndex].items[it] = m
                foundRowIndex = it
                break
            }
        }
        guard foundRowIndex != nil else {
            return nil
            
        }
        return IndexPath(row: foundRowIndex, section: foundSectionIndex)
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
        if indexPath.section == 0 {
            print(0)
        }
        
        if message.type == .text {
            let textCell = tableView.dequeueReusableCell(withIdentifier: TextMessageCell.ID, for: indexPath) as! TextMessageCell
            textCell.delegate = self
            cell = textCell
        } else if message.type == .image{
            if message.urls.count > 1 || message.mediaPreps?.count ?? 0 > 1 {
                let gridCell = tableView.dequeueReusableCell(withIdentifier: ImageGridCell.ID) as! ImageGridCell
                gridCell.gridCellDelegate = self
                cell = gridCell
            } else {
                let imCell = tableView.dequeueReusableCell(withIdentifier: ImageCell.ID) as! ImageCell
                imCell.imageCellDelegate = self
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
        
        if let fk = message.referenceFK, message.referredMessage == nil{
            interactor?.getReferredMessage(of: message){ m in
                guard let mfk = m else {
                    print("\(self) Failed finding reference Message: \(fk)")
                    return
                }
                DispatchQueue.main.async {
                    
                tableView.beginUpdates()
                    cell.configureReferenceView(mfk)
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                tableView.endUpdates()
                }
            }
        }
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

// MARK: - GridCellDelegate
extension MessageListViewController : GridCellDelegate {
    
    func rectSelectedCell () -> CGRect? {
        guard let cell = selectedCell else {
            return nil
        }
        return cell.convert(cell.bounds, to: view)
    }
    
    func didSelect(i: Int, of message: MessageDomain, from vc: UICollectionView) {
        guard let selectedIndex = vc.indexPathsForSelectedItems?.first,
              let selectedCell = vc.cellForItem(at: selectedIndex) as? PhotoViewGridCell else{
            return
        }
        // Was the image cropped?
        var fullView : UIView? = nil
        self.selectedCell = selectedCell
        if let ratio = message.mediaPreps?[i].ratioHW {
            let layoutRatio = selectedCell.frame.height / selectedCell.frame.width
            let isCropped : Bool = abs(ratio - layoutRatio) > 0.05
            if let im = selectedCell.imageView.image , isCropped {
                // if it's cropped, first animate reveal
                /// add the fullsize image view
                fullView = UIImageView(image: im)
                fullView?.contentMode = .scaleAspectFill
                fullView?.clipsToBounds = true
                
                fullView!.transform = CGAffineTransform(scaleX: 1, y: -1)
                let cellRect = selectedCell.convert(selectedCell.bounds, to: view)
                view.addSubview(fullView!)
                shouldRemoveAnimatable = true
                fullView!.frame = CGRect(x: cellRect.origin.x, y: cellRect.origin.y,
                                        width: cellRect.height / ratio, height: cellRect.height)
                fullView!.center = CGPoint(x: cellRect.origin.x + cellRect.width / 2,
                                          y: cellRect.origin.y + cellRect.height / 2)
                print("fullrect, ", fullView?.frame)
                let fullRect = fullView!.frame
                fullView?.frame = cellRect
                print("cell ", fullView?.frame)
                UIView.animate(withDuration: 1, animations: {
                    fullView?.frame = fullRect
                }, completion: { [weak self] _ in
                    self?.animatableView = fullView
                    self?.sourceSnapshot = fullView?.snapshotView(afterScreenUpdates: false)
                    self?.router?.toMediaView(i: i, of: message)
                })
                /// animate reveal
//                fullView!.animateReveal(centerSize: CGSize(width: cellRect.width, height: cellRect.height), willReveal: true, completion: { [weak self] in
//                    print("done")
//                    self?.animatableView = fullView
//                    self?.sourceSnapshot = fullView?.snapshotView(afterScreenUpdates: false)
//                    self?.router?.toMediaView(i: i, of: message)
//
//                })

                print("what first")
                return
            }
        }
        
        animatableView = fullView ?? selectedCell.imageView
//        sourceSnapshot = animatableView?.snapshotView(afterScreenUpdates: false)
        sourceSnapshot = fullView ?? animatableView?.snapshotView(afterScreenUpdates: false)
        router?.toMediaView(i: i, of: message)
        fullView?.removeFromSuperview()
        
    }
}

extension MessageListViewController : ImageCellDelegate {
    func didTap(_ cell: ImageCell) {
        animatableView = cell.myImageView
        sourceSnapshot = animatableView?.snapshotView(afterScreenUpdates: false)
        router?.toMediaView(i: 0, of: cell.message)
    }
}

// MARK: - Presenter
extension MessageListViewController : MessagesPresenter {
    
    func reloadMessage(_ msg: MessageDomain) {
        reloadMessageCell(m: msg)
    }

    func presentFFMessageStatus() {
        var section = 0
        var row = 0
        var listUpdatedRow : [IndexPath] = []
        while dateSections[section].items[row].status != .seen{
            listUpdatedRow.append(IndexPath(row: row, section: section))
            dateSections[section].items[row].status = .seen
            let items = dateSections[section].items
            row = row < items.count - 1 ? row+1 : 0
            if row == 0 {
                if section == dateSections.count - 1 {
                    break
                } else {
                    section += 1
                }
            }
        }
        if section < dateSections.count && row < dateSections[section].items.count{
            listUpdatedRow.append(IndexPath(row: row, section: section))
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: listUpdatedRow, with: .fade)
        }
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
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: sIndex)], with: .fade)
                }
            }
        }
    }
    

    
    
    func presentMessageStatus(id: String, status: MessageStatus) {
        for sec in 0..<dateSections.count{
            for row in 0..<dateSections.count {
                if dateSections[sec].items[row].mid == id {
                    DispatchQueue.main.async {
                        self.dateSections[sec].items[row].status = status
                        self.tableView.reloadRows(at: [IndexPath(row: row, section: sec)], with: .automatic)
                    }
                    return
                }
            }
        }
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
// MARK: - MessageCellDelegate
extension MessageListViewController : MessageCellDelegate {
    func tapRepliedCell(_ cell: MessageCell) {
        guard let referredMsg = cell.message.referredMessage,
            let goToPath = getIndexPath(of: referredMsg) else{
            return
        }
        
        tableView.scrollToRow(at: goToPath, at: .bottom, animated: true)
        
    }
    
    func swipe(_ cell: MessageCell) {
        currentReference = cell.message
        parentDelegate?.messageDidReply(cell.message)
    }
}

// MARK: - AnimatableViewController
extension MessageListViewController : PopAnimatableViewController {
    func getSourceSnapshot() -> UIView? {
        sourceSnapshot
    }
    
    func getWindow() -> UIWindow? {
        view.window
    }
    
    func getView() -> UIView {
        return view.superview ?? view
    }
    
    func getAnimatableView() -> UIView {
        return animatableView!
    }
    
    func animatableViewRect() -> CGRect {
        let window = self.view.window
        let rect = animatableView!.convert(animatableView!.bounds, to: window)
//        let rect = myTableView.convert(animatableView!.bounds, to: nil)
//        print("animatable rect: \(rect)")
        return rect
    }
    
    
}
