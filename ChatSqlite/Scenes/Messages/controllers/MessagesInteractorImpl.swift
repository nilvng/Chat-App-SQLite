//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit

protocol MessagesPresenter : AnyObject{
    func presentItems(_ items: [MessageDomain]?)
    func presentMoreItems(_ items : [MessageDomain]?)
    func presentReceivedItem(_ item : MessageDomain)
    func presentSentItem(_ item: MessageDomain)
    func loadConversation(_ c: ConversationDomain)

}

class MessagesInteractorImpl : MessageListInteractor {
    
    weak var presenter : MessagesPresenter?
    
    var registerSelfAction : ((String) -> Void )?
    
    var localStore : ChatLocalLogic
    
    var conversation : ConversationDomain!
    var newFriend : FriendDomain?
    
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(400)
    }
    var currPage = 0
    
    init(){
        localStore = SQLiteManager.shared
    }
    
    
        
    func fetchData(friend : FriendDomain){
        // find conversation with friend
        localStore.loadConversationWith(fid: friend.id, completionHandler: { res, err in
            // found it
            if let c = res {
                //print("Mediator: past chat")
                self.fetchData(conversation: c)
                self.conversation = c
                self.registerSelf()
                //print(c)
                self.presenter?.loadConversation(c)
            } else {
                //print("Mediator: new chat")
                // if conversation not exist
                self.conversation = ConversationDomain.fromFriend(friend: friend)
                self.newFriend = friend
                self.presenter?.loadConversation(self.conversation)
            }

        })

    }
    
    func fetchData(conversation: ConversationDomain){
        // filter messenges belong to this conversation
        
        self.conversation = conversation
        
        localStore.loadMessages(cid: conversation.id,noRecords: noRecords, noPages: 0, desc: true) { [weak self] msgs, err in
            self?.presenter?.presentItems(msgs)
            
        }
    }
    
    func loadMore(tableOffset : CGFloat){
        //print(tableOffset)
        
        let pages = Int(tableOffset / offSet)
        guard pages - currPage >= 1 else {
            return
        }
        currPage = pages

        localStore.loadMessages(cid: conversation.id, noRecords: noRecords, noPages: currPage, desc: true) { [weak self] msgs, err in
            // empty result -> no need to present
            if msgs == nil || msgs!.isEmpty || err != nil {
                print("empty fetch!: \(String(describing: self?.currPage))")
                return
                
            }
            self?.presenter?.presentMoreItems(msgs)
            
        }
    }

    func onSendMessage(content: String){
        // display message
        let m = MessageDomain(mid: UUID().uuidString,
                              cid: conversation.id,
                              content: content, type: .text,
                              timestamp: Date(), sender: "1")
        
        self.presenter?.presentSentItem(m)

        // update db
        localStore.saveNewMessage(msg: m, conversation: conversation, friend: newFriend)
        newFriend = nil

        // publish changes to server....
        
        // register to workerManager
        self.registerSelf()
        
    }
    
    // pass only once
    func registerSelf(){
        self.registerSelfAction?(conversation.id)
        registerSelfAction = nil
    }
    
}
