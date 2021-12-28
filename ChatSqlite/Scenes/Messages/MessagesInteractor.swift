//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit

protocol MessagesPresenter : AnyObject{
    func presentAllItems(_ items : [MessageDomain]?)
    func presentNewItem(_ item : MessageDomain)
}

class MessagesInteractor : MessagesDislayLogic {
    
    weak var presenter : MessagesPresenter?
    
    var store : MessageService?
    lazy var conversationStore : ConversationService = ConversationStoreProxy.shared
    
    var conversation : ConversationDomain!
    
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(300)
    }
    var currPage = 0
        
    func fetchData(friend : FriendDomain){
        // find conversation with friend
        conversationStore.findItemWithFriend(id: friend.id, completion: { res, err in
            // found it
            if let c = res {
                print("past chat")
                self.fetchData(conversation: c)
            } else {
                print("new chat")
                // if conversation not exist
                self.conversation = ConversationDomain.fromFriend(friend: friend)
                self.presenter?.presentAllItems(nil)
            }

        })

    }
    
    func fetchData(conversation: ConversationDomain){

        // filter messenges belong to this conversation
        self.conversation = conversation
        
        createWorker(cid: conversation.id)
        store!.fetchAllItems(noRecords: noRecords, noPages: 0, desc: false) { [weak self] msgs, err in
            self?.presenter?.presentAllItems(msgs)
            
        }
    }
    
    func createWorker(cid : String){
        if store == nil {
            self.store = MessageWorkerManager.shared.get(cid: cid)
            
        }
    }
    
    func onScroll(tableOffset : CGFloat){
        //print(tableOffset)
        let pages = Int(tableOffset / offSet)
        guard pages - currPage >= 1 else {
            return
        }
        currPage = pages
        print(pages)

        store?.fetchAllItems(noRecords: noRecords, noPages: currPage, desc: false) { [weak self] msgs, err in
            if msgs == nil || msgs!.isEmpty || err != nil {
                print("empty fetch!: \(String(describing: self?.currPage))")
                return
                
            } // empty result -> no need to present
            self?.presenter?.presentAllItems(msgs)
            
        }
    }

    func sendMessage(content: String, newConv : Bool  = true){
        if newConv {
            // create conversation
            conversationStore.createItem(conversation, completionHandler: { [weak self] c, err in
                guard let c = c else {
                    return
                }
                self?.conversation = c
                print("Conversation added.")
                self?.saveMessage(content: content)
            })
        } else {
            // create messenge
            saveMessage(content: content)
        }
        

    }
    
    func saveMessage(content: String){
        let m = MessageDomain(cid: conversation.id, content: content, type: .text, timestamp: Date(), sender: "1")
        
        createWorker(cid: conversation.id) // if needed
        
        store!.createItem(m, completionHandler: {  [weak self] msg, err in
            if msg != nil && err == nil {
                print("Messages saved.")
                self?.updateLastMessage(m: msg!)
                self?.presenter?.presentNewItem(msg!)
            } else {
                print(err?.localizedDescription ?? "Unknown error")
            }
        })
    }
    
    func updateLastMessage( m: MessageDomain){
        // update lastMessage
        conversation.lastMsg = m.content
        conversation.timestamp = m.timestamp
        
        conversationStore.updateItem(conversation, completionHandler: {
            c, err in
            if err == nil {
                print("Successfully update last message.")
            } else {
                print(err?.localizedDescription  ?? "weird error")
            }
        })
    }
    
    func toDbConversationModel(_ conversation: ConversationDomain) -> Conversation{
        var  i = ConversationSQLite()
        i.fromUIModel(c: conversation)
        return i
    }
    func toDbMsgModel(_ message: MessageDomain) -> Message{
        var  i = MessageSQLite()
        i.fromUIModel(c: message)
        return i
    }
}
