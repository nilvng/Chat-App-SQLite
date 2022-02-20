//
//  ChatServiceManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation

class ChatServiceManager {
    static var shared = ChatServiceManager()
    var cachedService : [String : ChatService] = [:]
    var convService : ConversationService?
    private init(){
        convService = ConversationStoreProxy.shared
    }
    
    func getChatService(for friend: FriendDomain) -> ChatService{
        let conv = ConversationDomain.fromFriend(friend: friend)
        let service = ChatService(conversation: conv, callback: caching)
        convService?.findItemWithFriend(id: friend.id, completion: {item, err in
            guard let found = item else {
                return
            }
            service.reset(conversation: found)
        })
        return service
    }
    
    func getChatService(for conversation : ConversationDomain) -> ChatService{
        if let found = cachedService[conversation.id] {
            return found
        }
        
        let one = ChatService(conversation: conversation, callback: caching)
        return one
    }
    
    func caching(cid: String, service: ChatService){
        self.cachedService[cid] = service

    }
}
