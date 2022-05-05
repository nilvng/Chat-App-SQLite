//
//  ChatService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation
import Photos

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
        let uid = UserSettings.shared.getUserID()
        socketService.sendMessageState(msg: msg, status: .arrived, from: uid)
        self.addMessage(msg: msg)
        // send ack
        
    }
    func createNewMessage(type: MessageType) -> MessageDomain{
        let cid = conversatioNWorker.getId()
        return MessageDomain(cid: cid, type: type)
    }
    // from the current user to their friend
    internal func updatetoSeen(){
        if conversatioNWorker.model.status != .seen {
            socketService.sendStateSeen(of: conversatioNWorker.model)
            conversatioNWorker.updateMessageStatus(mid: nil, .seen) // Force to "seen" because it's done local
        }
    }
    
    // called by their friends to current user
    func updateMessageStatus(mid: String, status: MessageStatus){
        // TODO: Swich case msg status
        switch status {
        case .sent:
            print("nah")
            break
        case .received:
            print("nah")
            break
        case .arrived:
            conversatioNWorker.updateMessageStatus(mid: mid, status)
            messageWorker.updateState(id: mid, status: status)
        case .seen:
            conversatioNWorker.updateMessageStatus(mid: mid, status)
            messageWorker.updateToSeenState()
            
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
