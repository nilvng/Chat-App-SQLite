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
    var orphanMessage: [String: Any] = [:]
    
    private init(){
        convService = ConversationStoreProxy.shared
    }
    
    func getChatService(for friend: FriendDomain) -> ChatService{
        let conv = ConversationDomain.fromFriend(friend: friend)
        let service = ChatService(conversation: conv, callback: caching)
        convService?.findItemWithFriend(id: friend.id, completion: {item, err in
            guard let found = item else {
                print("\(self) Cant find friend \(friend.id)")
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
        cachedService[conversation.id] = one
        return one
    }
    func getChatService(cid : String, completion: @escaping (ChatService?) -> Void){
        if let found = cachedService[cid] {
            completion(found)
            return
        }
        convService?.fetchItemWithId(cid, completionHandler: { [weak self] item, err in
            guard let found = item else {
                print("\(String(describing: self))Error: Cant find conversation \(cid)")
                completion(nil)
                return
            }
            let service = ChatService(conversation: found, callback: nil)
            self?.cachedService[cid] = service
            completion(service)
        })
    }
    
    func caching(cid: String, service: ChatService){
        self.cachedService[cid] = service

    }
}

extension ChatServiceManager : SocketDelegate {
    
    func connected() {
        print("Delegate: connected")
    }
    
    func disconnected() {
        print("Delegate: disconnected")

    }
    
    func onRetryFailed() {
        print("Delegate: retry failed")

    }
    
    func onMessageSent() {
        print("Delegate: message sent")

    }
    
    func onMessageReceived(msg: MessageDomain) {
        print("Delegate: message received from \(msg.cid)")
        
        if msg.cid == UserSettings.shared.getUserID() {
            msg.cid = msg.sender
        }
        // find in caches
        getChatService(cid: msg.cid, completion: { item in
            if let foundService = item {
                foundService.receiveMessage(msg)
            } else {
                print("\(self)Error: Cant find Chat service \(msg.cid)")
            }
        })
        
    }
    
    func onMessageStatusUpdated(cid: String, mid: String, status: MessageStatus) {
        print("Delegate: message updated")
        
        getChatService(cid: cid, completion: { item in
            if let foundService = item {
                foundService.updateMessageStatus(mid: mid, status: status)
            } else {
                print("\(self)Error: Cant find Chat service \(cid)")
            }
        })

    }
    
    
}
