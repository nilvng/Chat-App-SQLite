//
//  ChatService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation

class ChatService {
    typealias RegisterAction = (String ,ChatService) -> Void
  
    var conversatioNWorker : ConversationWorker
    var messageWorker : MessageListWorker
    var registerAction : RegisterAction?
    
    var socketService : SocketService = SocketService.shared
    
    init(conversation: ConversationDomain, callback: RegisterAction? = nil) {
        self.messageWorker = MessageListWorker(cid: conversation.id)
        self.conversatioNWorker = ConversationWorker(model: conversation)
        self.registerAction = callback
    }
    init(conversatioNWorker: ConversationWorker) {
        self.messageWorker = MessageListWorker(cid: conversatioNWorker.getId())
        self.conversatioNWorker = conversatioNWorker
    }
    
    func reset(conversation: ConversationDomain){
        let observer = messageWorker.observer
        self.messageWorker = MessageListWorker(cid: conversation.id)
        self.messageWorker.observer = observer
        self.conversatioNWorker = ConversationWorker(model: conversation)
        self.messageWorker.observer?.onFoundConversation(conversation)
        }
    
    func sendMessage(_ msg: MessageDomain){
        self.addMessage(msg: msg)
        socketService.sendMessage(msg)

    }
    
    func receiveMessage(_ msg: MessageDomain){
        self.addMessage(msg: msg)
        // send ack
        let uid = UserSettings.shared.getUserID()
        socketService.sendMessageState(msg: msg, status: .arrived, from: uid)
        
    }
    func updateMessageStatus(mid: String?, status: MessageStatus){
        // update at conv level
        conversatioNWorker.updateMessageStatus(status)
        // update at msg level
        if mid != nil || mid != "" {
            // update 1 msg
            messageWorker.updateState(id: mid!, status: status)
        } else {
            // update all msg status to seen
            print("\(self) tbd: present seen animation...")
        }
    }
    private func addMessage(msg : MessageDomain){
 
        // update last message & insert new conv if not created already
        conversatioNWorker.updateLastMessage(msg: msg)
        
        // add to db
        let _ = messageWorker.add(msg)
        
        // insert friend if not created
        
        // register itself to Manager
        if registerAction != nil {
            self.registerAction?(msg.cid, self)
            self.registerAction = nil
        }
        
    }
    
    func observeMessageList(observer: MessagesPresenter){
        messageWorker.observer = observer
    }
    
    func loadMessages(noRecords: Int, noPages: Int){
            messageWorker.requestGetAll(noRecords: noRecords, noPages: noPages)
    }
    
}
