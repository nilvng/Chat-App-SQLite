//
//  ConversationWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation

class ConversationWorker {
    
    var model : ConversationDomain
    var dbStore : ConversationService
    
    init(model: ConversationDomain, dbStore: ConversationService = ConversationStoreProxy.shared) {
        self.model = model
        self.dbStore = dbStore
    }
    
    func getId() -> String{
        return model.id
    }
    
    func updateLastMessage(msg: MessageDomain){
        model.lastMsg = msg.content
        model.timestamp = msg.timestamp
        dbStore.upsertItem(model, completionHandler: handleError)
    }
    func update(){
        dbStore.updateItem(model, completionHandler: handleError)
    }
    
    func save(){
        dbStore.createItem(model, completionHandler: handleError)
    }
    
    func delete(){
        dbStore.deleteItem(id: model.id, completionHandler: handleError)
    }
    
    fileprivate func handleError(err : StoreError?){
        print(err?.localizedDescription ?? "Successfully update Conversation.")
    }
}
