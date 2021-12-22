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

class MessagesInteractor : MessagesBusinessLogic {
    
    weak var presenter : MessagesPresenter?
    
    var store : MessagesSQLStore!
    lazy var conversationStore = ConversationStoreWorker.getInstance()
    
    var conversation : ConversationsModel!
    var noRecords : Int = 13
    var offSet : CGFloat {
        CGFloat(noRecords * 2)
    }
    var currPage = 0
    
    
    func fetchData(friend : Friend){
        // find conversation with friend
        conversationStore.findWithFriend(friend){ res, err in
            // found it
            if let c = res {
                self.fetchData(conversation: c)
            } else {
                
                // if conversation not exist
                self.conversation = ConversationsModel.fromFriend(friend: friend)
                self.presenter?.presentAllItems(nil)
            }

        }

    }
    
    func fetchData(conversation: ConversationsModel){
        
        if store == nil {
            store = MessagesSQLStore(cid: conversation.id)
        }
        
        // filter messenges belong to this conversation
        self.conversation = conversation
        store.getAll(conversationID: conversation.id,
                     noRecords: noRecords, noPages: 0) { [weak self] msgs, err in
            self?.presenter?.presentAllItems(msgs)
            
        }
    }
    
    func onScroll(tableOffset : CGFloat){
        print(tableOffset)
        let pages = Int(tableOffset / offSet)
        print(pages)
        guard pages - currPage >= 1 else {
            return
        }
        currPage = pages
        
        store.getAll(conversationID: conversation.id,
                     noRecords: noRecords, noPages: pages) { [weak self] msgs, err in
            if msgs == nil || msgs!.isEmpty {return}
            self?.presenter?.presentAllItems(msgs)
            
        }
    }

    func sendMessage(content: String, newConv : Bool){
        var m : MessageSQLite!
        if newConv {
            // create conversation
            conversationStore.create(newItem: self.conversation, completionHandler: { [weak self] c, err in
                guard let conv = c else {
                    return
                }
                m = MessageSQLite(cid: conv.id, content: content, type: .text, timestamp: Date(), sender: "1")
                // create new messege
                self?.store.create(newItem: m, completionHandler: { msg, err in
                    if msg != nil && err == nil {
                        self?.updateLastMessage(m: msg!)
                        self?.presenter?.presentNewItem(msg!)
                    }
                })
            })
        } else {
            // create messenge
            m = MessageSQLite(cid: conversation.id, content: content, type: .text, timestamp: Date(), sender: "1")
            store.create(newItem: m, completionHandler: {  [weak self] msg, err in
                if msg != nil && err == nil {
                    self?.updateLastMessage(m: msg!)
                    self?.presenter?.presentNewItem(msg!)
                }
            })
        }
        

    }
    
    func updateLastMessage( m: Message){
        // update lastMessage
        conversation.lastMsg = m.content
        conversation.timestamp = m.timestamp
        
        conversationStore.update(item: conversation, completionHandler: {
            c, err in
            if err != nil {
                print("Successfully update last message.")
            } else {
                print(err!.localizedDescription)
            }
        })
    }
    
    func toDtbModel(conversation: Conversation) -> ConversationSQLite{
        return ConversationSQLite(theme: conversation.theme, thumbnail: conversation.thumbnail, title: conversation.title, id: conversation.id, members: conversation.members, lastMsg: conversation.lastMsg, timestamp: conversation.timestamp)
    }
}
