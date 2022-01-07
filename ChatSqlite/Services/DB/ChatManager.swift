//
//  MessageWorkerManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/12/2021.
//

import Foundation

protocol ChatBusinessLogic {
    func onNewMessage(msg: MessageDomain, conversation: ConversationDomain, isNewConv: Bool)
    func reactMessage(msg: MessageDomain)
}

protocol ConversationBusinessLogic{
    func onDeleteConversation(id: String)
}

class ChatManager{
    static var shared = ChatManager()
    var workers = [String: MessageService]()
    var convService : ConversationService
    var friendService : FriendService
    
    private init(){
        convService = ConversationStoreProxy.shared
        friendService = FriendStoreProxy.shared
    }
    
    func get(cid: String) -> MessageService{
        if let w = workers[cid] {
            return w
        }
        // create proxy worker
        let w = MessageStoreProxy(cid: cid)
        workers[cid] = w
        return w
    }
}

extension ChatManager : ChatBusinessLogic{
    func reactMessage(msg: MessageDomain) {
        fatalError("tbd")
    }
    
    func onNewMessage(msg: MessageDomain, conversation: ConversationDomain, isNewConv: Bool){
        
        // Add new msg to msgService
        let store = get(cid: msg.cid)
        store.createItem(msg, completionHandler: {  err in
            if err == nil {
                print("Messages saved.")
            } else {
                print(err?.localizedDescription ?? "Unknown error")
            }
        })
        
        // Update last msg (possibly add new conv) to ConvService
        var conCopy = conversation
        conCopy.lastMsg = msg.content
        conCopy.timestamp = msg.timestamp
        //print(conCopy)
        
        convService.upsertItem(conCopy, completionHandler: { err in
            guard err == nil else {
                print(err!.localizedDescription)
                return
            }
            print("Conversation added.")
        })
    }
    


}

extension ChatManager : ConversationBusinessLogic{
    
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
