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
    
    var db : Connection!
    var items : [Conversation] = []
    
    var table = Table("Conversation")
    var id = Expression<String>("id")
    var title = Expression<String>("title")
    var members = Expression<String>("members")
    var thumbnail = Expression<String>("thumbnail")
    var lastMsg = Expression<String>("lastMsg")
    var timestamp = Expression<String>("timestamp")

    
    private init(){
        getInstance(path: "chat-conversation.sqlite")
        createTable()
        
    }
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool = true, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void) {
        do {
            let queries = table.order(timestamp.desc)
                .limit(noRecords, offset: noRecords * noPages)
            
            let result : [ConversationSQLite] = try db!.prepare(queries).map { row in
                return try row.decode()
            }
            items = result
            print("fetch all:\(items)")
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
                
        let path = dir.appendingPathComponent(subPath)
        print(path)
        
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
            t.column(lastMsg)
            t.column(timestamp)
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
        guard let itemSql = item as? ConversationSQLite else {
            completionHandler(nil,.cantUpdate("Wrong model type."))
            return
        }
        try! db.run(table.filter(id == item.id).update(itemSql))
    }
    
    func delete(id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
    
}
