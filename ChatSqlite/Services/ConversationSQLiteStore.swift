//
//  ConversationsAPIs.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import SQLite

class ConversationSQLiteStore {
    
    static var shared = ConversationSQLiteStore()
    
    var db : Connection?
    var items : [Conversation] = []
    
    var table = Table("Conversation")
    var id = Expression<String>("id")
    var title = Expression<String>("title")
    var members = Expression<String>("members")
    var thumbnail = Expression<String>("thumbnail")
    
    private init(){
        getInstance(path: "chat-conversation.sqlite")
        createTable()
        
    }
    
    func getAll(completionHandler: @escaping ([Conversation]?, StoreError?) -> Void) {
        
        do {
            
            let result : [ConversationSQLite] = try db!.prepare(table).map { row in
                return try row.decode()
            }
            items = result
            completionHandler(items,nil)
        } catch let e{
            print(e.localizedDescription)
            completionHandler(nil,.cantFetch("Cant fetch"))
        }
        
    }
    
    func getInstance(path subPath : String){
        let dirs: [NSString] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                               FileManager.SearchPathDomainMask.allDomainsMask, true) as [NSString]
                   
                 
        let dir = dirs[0]
                
        let path = dir.appendingPathComponent(subPath);
            
        do{
            db = try Connection(path)
        } catch let e{
            db = nil
            print(e.localizedDescription)
        }
        
    }
    
    func createTable(){
        do{
        try db?.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(members)
        })
        } catch let e {
            print(e.localizedDescription)
        }
    }

    
    func getWithId(_ id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
    func create(newItem: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        do {
            guard let sqliteObject = newItem as? ConversationSQLite else {
                completionHandler(nil, .cantFetch("SQLite Error: Cannot add non-SQLite object"))
                return
            }
            let rowid = try db?.run(table.insert(sqliteObject))
            
            print("Create Conversation row: \(String(describing: rowid))")
            completionHandler(newItem, nil)
        } catch let e {
            print("store failed: " + e.localizedDescription)
            completionHandler(nil,.cantCreate(e.localizedDescription))
        }
    }
    
    func update(item: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
    
}
