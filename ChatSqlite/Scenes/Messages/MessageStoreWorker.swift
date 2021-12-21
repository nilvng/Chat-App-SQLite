//
//  MessageStoreWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/12/2021.
//

import Foundation

// converting models from and to UI format
// handle callback in main thread
class MessageStoreWorker {
    var store : MessagesSQLStore
    
    init (store: MessagesSQLStore){
        self.store = store
    }
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool = true, completionHandler: @escaping ([Message]?, StoreError?) -> Void) {
        
        
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func create(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {

    }
    
    func update(item: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
}
