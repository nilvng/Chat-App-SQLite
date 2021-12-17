//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit

protocol MessengesPresenter : AnyObject{
    func presentAllItems(_ items : [Message]?)
    func presentNewItem(_ item : Message)
}
class MessengesInteractor {
    weak var presenter : MessengesPresenter?
    
    var store : MessengesSQLStore = MessengesSQLStore()
    var conversationStore = ConversationSQLiteStore.shared
    
    var conversation : Conversation!
    var noRecords : Int = 13
    var offSet : CGFloat {
        CGFloat(noRecords * 2)
    }
    var currPage = 1
    
    
    func fetchData(friend : Friend){
        // find conversation with friend
        
        // found it
        
        // if conversation not exist
        let conversation = ConversationSQLite(theme: nil,
                                              thumbnail: nil,
                                              title: friend.name,
                                              id: UUID().uuidString, members: friend.id)
        self.conversation = conversation
        presenter?.presentAllItems(nil)
    }
    
    func fetchData(conversation: Conversation, noPages: Int = 1){
        // filter messenges belong to this conversation
        self.conversation = conversation
        store.getAll(conversationID: conversation.id,
                     noRecords: noRecords, noPages: noPages) { [weak self] msgs, err in
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

    func sendMessenge(_ msg: Message, newConv : Bool){
        if newConv {
            // create conversation
            conversationStore.create(newItem: conversation, completionHandler: { [weak self] c, err in
                guard let conv = c else {
                    return
                }
                var m = msg
                m.conversationId = conv.id
                
                // create new messege
                self?.store.create(newItem: m, completionHandler: { msg, err in
                    if err == nil {
                        self?.presenter?.presentNewItem(msg!)
                    }
                })
            })
        } else {
            store.create(newItem: msg, completionHandler: {  [weak self] msg, err in
                if err == nil {
                    self?.presenter?.presentNewItem(msg!)
                }
            })
        }
    }
}
