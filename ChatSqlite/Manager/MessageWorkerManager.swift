//
//  MessageWorkerManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/12/2021.
//

import Foundation

class MessageWorkerManager{
    static var shared = MessageWorkerManager()
    var workers = [String: MessageStoreWorker]()
    
    private init(){
        
    }
    
    func get(cid: String) -> MessageStoreWorker{
        if let w = workers[cid] {
            return w
        }
        // create worker
        let w = MessageStoreWorker(cid: cid)
        workers[cid] = w
        return w
    }
}
