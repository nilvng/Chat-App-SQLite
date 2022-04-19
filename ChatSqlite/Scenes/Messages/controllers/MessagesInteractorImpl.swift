//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit
import Photos

protocol MessagesPresenter : AnyObject{
    func presentItems(_ items: [MessageDomain]?, offset: Int)
    func presentReceivedItem(_ item : MessageDomain)
    func presentSentItem(_ item: MessageDomain)
    func onFoundConversation(_ c: ConversationDomain)
    func presentMessageStatus(id: String, status: MessageStatus)
    func presentFFMessageStatus()
}

class MessagesInteractorImpl : MessageListInteractor {
            
    var chatService : ChatService
        
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(380)
    }
    var currPage = 0
    var selectedFriend : FriendDomain?
    
    func doneSelectLocalMedia(_ assets: [PHAsset]){
        chatService.sendMessage(assets)
    }
    
    internal init(chatService: ChatService, noRecords: Int = 20, currPage: Int = 0, selectedFriend: FriendDomain? = nil) {
        self.chatService = chatService
        self.noRecords = noRecords
        self.currPage = currPage
        self.selectedFriend = selectedFriend
    }


    func sendSeenStatus(){
        print("currently in Chat View")
        chatService.updatetoSeen()
    }
    
    func setSelectedFriend(friend : FriendDomain){
        // find conversation with friend
        //memoStore?.requestGetAll(noRecords: noRecords, noPages: 0)
        selectedFriend = friend

    }
    
    func loadData(){
        // filter messenges belong to this conversation
        chatService.loadMessages(noRecords: noRecords, noPages: 0)
        }
    
    func loadMore(tableOffset : CGFloat){
        //print(tableOffset)
        
        let pages = Int(tableOffset / offSet)
        guard pages - currPage == 1 else {
            return
        }
        currPage = pages

        chatService.loadMessages(noRecords: noRecords, noPages: pages)
    }

    func onSendMessage(content: String, conversation: ConversationDomain){
        // display message
        let m = MessageDomain(cid: conversation.id, content: content, type: .text, status: .sent)
        
        // update db
        chatService.sendMessage(m)
        
    }
    
    func onSendMessage(m: MessageDomain){
        chatService.sendMessage(m)
    }
    
    
}
