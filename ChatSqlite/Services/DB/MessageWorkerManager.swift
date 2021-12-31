//
//  MessageWorkerManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/12/2021.
//

import Foundation

class MessageWorkerManager{
    static var shared = MessageWorkerManager()
    var workers = [String: MessageService]()
    
    private init(){
        
    }
    
    func get(cid: String) -> MessageService{
        if let w = workers[cid] {
            return w
        }
        // create proxy worker
        let w = MessageStoreProxy(cid: cid)
        workers[cid] = w
        return w
    }
}