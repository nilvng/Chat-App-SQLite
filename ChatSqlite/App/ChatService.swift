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
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.ChatService",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    
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
        utilityQueue.async { [self] in
        let observer = messageWorker.observer
        self.messageWorker = MessageListWorker(cid: conversation.id)
        self.messageWorker.observer = observer
        self.conversatioNWorker = ConversationWorker(model: conversation)
        self.messageWorker.observer?.onFoundConversation(conversation)
        }
    }
    
    func sendMessage(_ msg: MessageDomain){
        self.addMessage(msg: msg)
        socketService.sendMessage(msg)

    }
    
    func receiveMessage(_ msg: MessageDomain){
        self.addMessage(msg: msg)
    }
    
    private func addMessage(msg : MessageDomain){
//        utilityQueue.async { [self] in
            
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
            
//        }
    }
    
    func observeMessageList(observer: MessagesPresenter){
        utilityQueue.async { [self] in
        messageWorker.observer = observer
        }
    }
    
    func loadMessages(noRecords: Int, noPages: Int){
        utilityQueue.async { [self] in
            messageWorker.requestGetAll(noRecords: noRecords, noPages: noPages)
        }
    }
    
}
