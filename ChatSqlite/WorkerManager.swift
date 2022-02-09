//
//  AppConfigurator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 09/02/2022.
//

import Foundation

class WorkerManager {
    
    static var shared = WorkerManager()
    
    var msgWorkers : [String: MessagesInteractorImpl] = [:]
    var conversationWorker = ConversationsInteractorImpl()
    //var socketWorker
    
    private init(){}
    
    func getMessageWorker(cid: String? = nil) -> MessagesInteractorImpl{
        if cid != nil && msgWorkers[cid!] != nil {
            return msgWorkers[cid!]!
        }
        
        let worker = MessagesInteractorImpl()
        
        worker.registerSelfAction = { cid in
            self.msgWorkers[cid] = worker
        }
        
        return worker
    
    }
    
    func getConversationWorker() -> ConversationsInteractorImpl{
        return conversationWorker
    }
    
    
    
}
