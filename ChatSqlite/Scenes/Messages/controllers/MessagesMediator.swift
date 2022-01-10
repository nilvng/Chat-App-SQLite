//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit

protocol MessagesPresenter : AnyObject{
    func showInitialItems(_ items: [MessageDomain]?)
    func presentMoreItems(_ items : [MessageDomain]?)
    func presentNewItem(_ item : MessageDomain)
    func loadConversation(_ c: ConversationDomain, isNew : Bool)

}

class MessagesMediator : MessageDBMediator {
    
    weak var presenter : MessagesPresenter?
    
    var manager : ChatBusinessLogic
    var store : MessageService?
    lazy var conversationStore : ConversationService = ConversationStoreProxy.shared
    
    var conversation : ConversationDomain!
    var newFriend : FriendDomain?
    
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(300)
    }
    var currPage = 0
    
    init(){
        manager = ChatManager.shared
    }
        
    func fetchData(friend : FriendDomain){
        // find conversation with friend
        manager.loadConversationWith(fid: friend.id, completionHandler: { res, err in
            // found it
            if let c = res {
                print("Mediator: past chat")
                self.fetchData(conversation: c)
                self.conversation = c
                print(c)
                self.presenter?.loadConversation(c, isNew: false)
            } else {
                print("Mediator: new chat")
                // if conversation not exist
                self.conversation = ConversationDomain.fromFriend(friend: friend)
                self.newFriend = friend
                self.presenter?.loadConversation(self.conversation, isNew: true)
            }

        })

    }
    
    func fetchData(conversation: ConversationDomain){

        // filter messenges belong to this conversation
        self.conversation = conversation
        
        manager.loadMessages(cid: conversation.id,noRecords: noRecords, noPages: 0, desc: true) { [weak self] msgs, err in
            self?.presenter?.showInitialItems(msgs)
            
        }
    }
    
    func createWorker(cid : String){
        if store == nil {
            self.store = ChatManager.shared.get(cid: cid)
            
        }
    }
    
    func loadMore(tableOffset : CGFloat){
        //print(tableOffset)
        let pages = Int(tableOffset / offSet)
        guard pages - currPage >= 1 else {
            return
        }
        currPage = pages

        manager.loadMessages(cid: conversation.id, noRecords: noRecords, noPages: currPage, desc: false) { [weak self] msgs, err in
            // empty result -> no need to present
            if msgs == nil || msgs!.isEmpty || err != nil {
                print("empty fetch!: \(String(describing: self?.currPage))")
                return
                
            }
            self?.presenter?.presentMoreItems(msgs)
            
        }
    }

    func sendMessage(content: String, newConv : Bool  = true){
        // show the user first
        
        let m = MessageDomain(cid: conversation.id, content: content, type: .text, timestamp: Date(), sender: "1")
        
        self.presenter?.presentNewItem(m)

        // update db
        manager.onNewMessage(msg: m, conversation: conversation)
        if let f = newFriend, newConv{
            manager.onNewFriend(friend: f)
        }
    }
    
}
