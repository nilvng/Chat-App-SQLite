//
//  ConversationWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation

class ConversationWorker {
    
    var model : ConversationDomain!
    var dbStore : ConversationServiceDecorator
    
    init(model: ConversationDomain, dbStore: ConversationServiceDecorator = ConversationServiceDecorator.shared) {
        self.model = model
        self.dbStore = dbStore
    }
    
    func getId() -> String{
        return model.id
    }
    
    func updateLastMessage(msg: MessageDomain){
        model.lastMsg = msg.content
        model.timestamp = msg.timestamp
        model.status = msg.status
        model.mid = msg.mid
        dbStore.upsertConversation(model)
        
    }
    
    func updateMessageStatus(mid: String?, _ status: MessageStatus){
        guard mid == nil || mid == model.mid else {
            return
        }
        model.status = status
        dbStore.updateConversation(model)
    }
    
    func update(){
        dbStore.upsertConversation(model)
    }
    
    func save(){
//        dbStore.add(model, completionHandler: handleError)
    }
    
    func delete(){
        dbStore.deleteConversation(id: model.id)
    }
    
    fileprivate func handleError(err : StoreError?){
        print(err?.localizedDescription ?? "Successfully update Conversation.")
    }
}
