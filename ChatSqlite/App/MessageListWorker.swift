//
//  MessageListWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation
class MessageListWorker {
    
    var dbStore : MessageDBService?
    weak var observer : MessagesPresenter?
    
    init(observer: MessagesPresenter){
        self.observer = observer
    }
    
    init(cid: String) {
        dbStore = MessageStoreProxy(cid: cid)
    }
    
    func setDBStore(store : MessageDBService){
        self.dbStore = store
    }
    
    func isBrandNew() -> Bool{
        return dbStore == nil
    }
    
    func loadInitialData(){
        dbStore?.fetchAllItems(noRecords: 20, noPages: 0, desc: true, completionHandler: { (msgs, err) in
            guard let msgs = msgs else {
                return
            }
            self.observer?.presentItems(msgs, offset: 0)
        })
    }
    
    func addObserver(_ obs : MessagesPresenter) {
        observer = obs
    }
    
    func requestGetAll(noRecords: Int, noPages: Int){
        dbStore?.fetchAllItems(noRecords: noRecords, noPages: noPages, desc: true, completionHandler: { [weak self](msgs, err) in
                guard let msgs = msgs else {
                    return
                }
                self?.observer?.presentItems(msgs, offset: noPages * noRecords)
                
            })
    }
    
    @discardableResult
    func add(_ msg: MessageDomain) -> Bool{
        observer?.presentSentItem(msg)
        dbStore?.createItem(msg, completionHandler: handleError)
        return true
    }
    
    func delete(id: String) -> Bool{
        dbStore?.deleteItem(id: id, completionHandler: handleError)
        return true
    }
    func update(id: String, with msg: MessageDomain) -> Bool{
        dbStore?.updateItem(msg, completionHandler: handleError)
        return true
    }
    
    func updateState(id: String, status: MessageStatus){
        dbStore?.updateStatus(id: id, status: status, completionHandler: handleError)
        observer?.presentMessageStatus(id: id, status: status)
    }
    
    func updateToSeenState(){
        dbStore?.ffUpdateStatus(completionHandler: handleError)
        observer?.presentFFMessageStatus()

    }
    
    fileprivate func handleError(err : StoreError?){
        print(err?.localizedDescription ?? "Successfully update Conversation.")
    }
}
