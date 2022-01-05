//
//  MessageWorkerManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/12/2021.
//

import Foundation

protocol ChatAppManager {
    
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
    
    func performDeleteConversation(_ c: ConversationDomain){
        // delete conversation
        
        // delete msgs of that conversation
    }
    
    func onNewMessage(msg: MessageDomain){
        // add new msg to msgService
        
        // update last msg in ConvService
    }
    
    
}
