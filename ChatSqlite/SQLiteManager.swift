//
//  MessageWorkerManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/12/2021.
//

import Foundation

protocol ChatLocalLogic {
    func loadConversationWith(fid: String, completionHandler: @escaping (ConversationDomain?, StoreError?) -> Void)
    func saveNewMessage(msg: MessageDomain, conversation: ConversationDomain, friend: FriendDomain?)
    func loadMessages(cid: String, noRecords: Int, noPages: Int, desc : Bool, completionHandler: @escaping ([MessageDomain]?, StoreError?) -> Void)

}

protocol ConversationLocalLogic {
    func loadConversations(noRecords: Int, noPages: Int, desc : Bool, completionHandler: @escaping ([ConversationDomain]?, StoreError?) -> Void)
    func onDeleteConversation(id: String)
    func filterConversation(by key: String, completion: @escaping ([ConversationDomain]?, StoreError?) -> Void)
}

class SQLiteManager{

    
    static var shared = SQLiteManager()
    var workers = [String: MessageService]()
    var convService : ConversationService
    var friendService : FriendService
    
    private init(){
        convService = ConversationStoreProxy.shared
        friendService = FriendStoreProxy.shared
    }
    
    func get(cid: String) -> MessageService{
        if let w = workers[cid] {
            //print("exisitng worker: \(cid)")
            return w
        }
        //print("create worker: \(cid)")
        // create proxy worker
        let w = MessageStoreProxy(cid: cid)
        workers[cid] = w
        return w
    }
}

extension SQLiteManager : ChatLocalLogic{
    
    func loadConversationWith(fid: String, completionHandler: @escaping (ConversationDomain?, StoreError?) -> Void) {
        convService.findItemWithFriend(id: fid, completion: completionHandler)
    }
    
    func loadMessages(cid: String, noRecords: Int, noPages: Int, desc: Bool, completionHandler: @escaping ([MessageDomain]?, StoreError?) -> Void) {
        let msgService = get(cid: cid)
        msgService.fetchAllItems(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: completionHandler)
    }
    
    func findMsgsWithFriend(_ friend: FriendDomain) {
        fatalError()
    }
    
    func reactMessage(msg: MessageDomain) {
        fatalError("tbd")
    }
    
    func saveNewMessage(msg: MessageDomain, conversation: ConversationDomain, friend: FriendDomain?){
        
        // Add new msg to msgService
        let store = get(cid: conversation.id)
        
        store.createItem(msg, completionHandler: {  err in
            if err == nil {
                print("Messages saved.")
            } else {
                print(err?.localizedDescription ?? "Unknown error")
            }
        })
        
        // Update last msg (and possibly add new conv) to ConvService
        var conCopy = conversation
        conCopy.lastMsg = msg.content
        conCopy.timestamp = msg.timestamp
        
        convService.upsertItem(conCopy, completionHandler: { err in
            guard err == nil else {
                print(err!.localizedDescription)
                return
            }
            print("Conversation upserted.")
        })
        
        // add to FriendStore if this is the first conversation with this friend
        if let f = friend {
            self.onNewFriend(friend: f)
        }
        
    }
    // save friend to sqlite db
    func onNewFriend(friend: FriendDomain){
        friendService.createItem(friend, completionHandler: { err in
            print(err?.localizedDescription ?? "")
        })
    }
    
    func updateMsg(_ msg : MessageDomain){
        guard let worker = workers[msg.cid] else {
            return
        }
        print("Message to update: \(msg)")
        worker.updateItem(msg, completionHandler: { err in
            if err != nil {
                print(err?.localizedDescription ?? "weird")
            }
        })
    }
    


}

extension SQLiteManager : ConversationLocalLogic{
    func filterConversation(by key: String, completion: @escaping ([ConversationDomain]?, StoreError?) -> Void) {
        convService.filterBy(key: key, completion: completion)
    }
    
    func loadConversations(noRecords: Int, noPages: Int, desc: Bool, completionHandler: @escaping ([ConversationDomain]?, StoreError?) -> Void) {
        convService.fetchAllItems(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: completionHandler)
    }
    
    
    func onDeleteConversation(id: String) {
        // delete in Conv table
        convService.deleteItem(id: id, completionHandler: { err in
            print(err?.localizedDescription ?? "successfully delete conv : \(id)")
        })
        let msgService = get(cid: id)
        // delete in Msg table
        msgService.deleteAllItems(completionHandler: { err in
            print(err?.localizedDescription ?? "successfully delete all msg of : \(id)")
        })
    }
}