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
    func onFoundConversation(_ c: ConversationDomain)

}

class MessagesInteractorImpl : MessageListInteractor {
            
    var memoStore : MessageMemoStore?
        
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(380)
    }
    var currPage = 0
    
        
    func fetchData(friend : FriendDomain){
        // find conversation with friend
        memoStore?.requestGetAll(noRecords: noRecords, noPages: 0)

    }
    
    func fetchData(conversation: ConversationDomain){
        // filter messenges belong to this conversation
        
        memoStore?.requestGetAll(noRecords: noRecords, noPages: 0)
    }
    
    func loadMore(tableOffset : CGFloat){
        //print(tableOffset)
        
        let pages = Int(tableOffset / offSet)
        guard pages - currPage == 1 else {
            return
        }
        currPage = pages

        memoStore?.requestGetAll(noRecords: noRecords, noPages: pages)
    }

    func onSendMessage(content: String, conversation: ConversationDomain){
        // display message
        let m = MessageDomain(mid: UUID().uuidString,
                              cid: conversation.id,
                              content: content, type: .text,
                              timestamp: Date(), sender: "1")
        
        // update db
        memoStore?.add(m)
        
    }
}
