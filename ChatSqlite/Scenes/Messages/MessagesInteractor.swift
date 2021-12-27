//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit

protocol MessagesPresenter : AnyObject{
    func presentAllItems(_ items : [Message]?)
    func presentNewItem(_ item : Message)
}

class MessagesInteractor : MessagesDislayLogic {
    
    weak var presenter : MessagesPresenter?
    
    var store : MessageDataLogic?
    lazy var conversationStore = ConversationStoreProxy.shared
    
    var conversation : ConversationsModel!
    
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(300)
    }
    var currPage = 0
        
    func fetchData(friend : Friend){
        // find conversation with friend
        conversationStore.findWithFriend(friend){ res, err in
            // found it
            if let c = res {
                self.fetchData(conversation: c.toUIModel())
            } else {
                
                // if conversation not exist
                self.conversation = ConversationsModel.fromFriend(friend: friend)
                self.presenter?.presentAllItems(nil)
            }

        }

    }
    
    func fetchData(conversation: ConversationsModel){

        // filter messenges belong to this conversation
        self.conversation = conversation
        
        createWorker(cid: conversation.id)
        store!.getAll(noRecords: noRecords, noPages: 0, desc: false) { [weak self] msgs, err in
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

        store?.getAll(noRecords: noRecords, noPages: currPage, desc: false) { [weak self] msgs, err in
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
            conversationStore.add(newItem: toDbConversationModel(conversation), completionHandler: { [weak self] c, err in
                guard let c = c else {
                    return
                }
                self?.conversation = c.toUIModel()
                print("Conversation added.")
                self?.saveMessage(content: content)
            })
        } else {
            // create messenge
            saveMessage(content: content)
        }
        

    }
    
    func saveMessage(content: String){
        let m = MessagesModel(cid: conversation.id, content: content, type: .text, timestamp: Date(), sender: "1")
        
        createWorker(cid: conversation.id) // if needed
        
        store!.add(newItem: toDbMsgModel(m), completionHandler: {  [weak self] msg, err in
            if msg != nil && err == nil {
                print("Messages saved.")
                self?.updateLastMessage(m: msg!)
                self?.presenter?.presentNewItem(msg!)
            } else {
                print(err?.localizedDescription ?? "Unknown error")
            }
        })
    }
    
    func updateLastMessage( m: Message){
        // update lastMessage
        conversation.lastMsg = m.content
        conversation.timestamp = m.timestamp
        
        conversationStore.update(item: toDbConversationModel(conversation), completionHandler: {
            c, err in
            if err == nil {
                print("Successfully update last message.")
            } else {
                print(err?.localizedDescription  ?? "weird error")
            }
        })
    }
    
    func toDbConversationModel(_ conversation: ConversationsModel) -> Conversation{
        var  i = ConversationSQLite()
        i.fromUIModel(c: conversation)
        return i
    }
    func toDbMsgModel(_ message: MessagesModel) -> Message{
        var  i = MessageSQLite()
        i.fromUIModel(c: message)
        return i
    }
}
