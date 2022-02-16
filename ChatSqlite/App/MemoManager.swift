//
//  MessageListMemoManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 14/02/2022.
//

import Foundation
import Combine

class MessageMemoManager {
    var messageList : [String : MessageMemoStore] = [:]
    static var shared = MessageMemoManager()
    
    func get(conversationID: String) -> MessageMemoStore{
        guard let store = messageList[conversationID] else {
            let store = MessageMemoStore(cid: conversationID)
            store.dbStore = SQLiteManager.shared.get(cid: conversationID)
            return store
        }
        return store
    }
    
    func get(friendID: String) -> MessageMemoStore {
        return MessageMemoStore(fid: friendID){ [weak self] (cid, store) in
                self?.messageList[cid] = store
            }
    }
}

class MessageMemoStore : ObservableObject {
    
    typealias RegisterAction = (String, MessageMemoStore) -> Void
    var registerValidSelfAction : RegisterAction?
    
    @Published var messages : [MessageDomain] = []
    var dbStore : MessageService?
    var doneFetchDB : Bool = false
    
    weak var observer : MessagesPresenter?
    var cid: String
    init(cid: String) {
        self.cid = cid
        self.loadInitialData()
    }
    
    init(fid: String, callback: RegisterAction? = nil ){
        self.cid = UUID().uuidString // stub data
        self.registerValidSelfAction = callback
        SQLiteManager.shared.loadConversationWith(fid: fid, completionHandler: { [weak self] c, err in
            guard let conv = c else {
                return
            }
            self?.registerValidSelfAction?(conv.id, self!)
            self?.cid = conv.id
            self?.observer?.onFoundConversation(conv)
            self?.loadInitialData()
        })
    }
    
    func loadInitialData(){
        SQLiteManager.shared.loadMessages(cid: cid, noRecords: 20, noPages: 0, desc: true, completionHandler: { [weak self](msgs, err) in
            guard let msgs = msgs else {
                return
            }

            self?.messages = msgs
        })
    }
    
    func addObserver(_ obs : MessagesPresenter) {
        observer = obs
    }
    
    func requestGetAll(noRecords: Int, noPages: Int){
        if messages.count > noRecords * noPages {
            let offset = noRecords * noPages
            self.observer?.presentItems(Array(messages[offset...offset+noRecords]))
        }else {
            if doneFetchDB {
                return
            }

            SQLiteManager.shared.loadMessages(cid: cid, noRecords: noRecords, noPages: noPages, desc: true, completionHandler: { [weak self](msgs, err) in
                guard let msgs = msgs else {
                    return
                }

                if msgs.count < noRecords {
                    self?.doneFetchDB = true
                }
                self?.messages.append(contentsOf: msgs)
                self?.observer?.presentMoreItems(msgs)
                
            })
        }
    }
    
    func add(_ msg: MessageDomain, conversation: ConversationDomain, withFriend friend: FriendDomain?) -> Bool{
        messages.append(msg)
        observer?.presentSentItem(msg)
        if let f = friend {
           // SQLiteManager.shared.saveNewFriendIfNeeded(f)
            SQLiteManager.shared.onNewFriend(friend: f)
        }
        SQLiteManager.shared.saveNewMessage(msg: msg, conversation: conversation)

        return true
    }
    func delete(id: String) -> Bool{
        guard let index =  messages.firstIndex(where: {$0.mid == id}) else {
            return false
        }
        // oserver...
        messages.remove(at: index)
        return true
    }
    func update(id: String, with msg: MessageDomain) -> Bool{
        guard let index =  messages.firstIndex(where: {$0.mid == id}) else {
            return false
        }
        // observer....
        messages[index] = msg
        return true
    }
}
