//
//  ConversationsAPIs.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import SQLite

class ConversationSQLiteStore {
        
    var db : Connection!
    var items : [ConversationSQLite] = []
    
    var table = Table("Conversation")
    var id = Expression<String>("id")
    var title = Expression<String>("title")
    var members = Expression<String>("members")
    var theme = Expression<String?>("theme")
    var thumbnail = Expression<String?>("thumbnail")
    var lastMsg = Expression<String>("lastMsg")
    var timestamp = Expression<String>("timestamp")

    
    init(){
        getInstance(path: "chat-conversation.sqlite")
        createTable()
        
    }
    
    func getInstance(path subPath : String){
        let dirs: [NSString] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                               FileManager.SearchPathDomainMask.allDomainsMask, true) as [NSString]
                   
                 
        let dir = dirs[0]
                
        let path = dir.appendingPathComponent(subPath)
        print(" dtb address: \(path)")
        
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
            t.column(theme)
            t.column(thumbnail)
            t.column(lastMsg)
            t.column(timestamp)
        })
        } catch let e {
            print(e.localizedDescription)
        }
    }
}

extension ConversationSQLiteStore : ConversationDataLogic{
    

    func getAll( noRecords : Int, noPages: Int, desc : Bool = true, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void) {
        do {
            var queries = table.limit(noRecords, offset: noRecords * noPages)
                
            queries = desc ? queries.order(timestamp.desc) : queries.order(timestamp.asc)
            
            let result : [ConversationSQLite] = try db!.prepare(queries).map { row in
                return try row.decode()
            }
            items = result
            completionHandler(items,nil)
        } catch let e{
            print(e.localizedDescription)
            completionHandler(nil,.cantFetch("Cant fetch"))
        }
        
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
    func add(newItem: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        guard let item = newItem as? ConversationSQLite else {
            completionHandler(nil, .cantFetch("wrong type"))
            return
        }
        
        do {
            print(newItem)

            let rowid = try db?.run(table.insert(item))
            
            print("Create Conversation row: \(String(describing: rowid))")
            completionHandler(newItem, nil)
        } catch let e {
            print("store failed: " + e.localizedDescription)
            completionHandler(nil,.cantCreate(e.localizedDescription))
        }
    }
    
    func update(item: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {

        guard let item = item as? ConversationSQLite else {
            completionHandler(nil, .cantFetch("wrong type"))
            return
        }
        do {
            try db.run(table.filter(id == item.id).update(item))
            print("update conversation: \(String(describing: item.id))")
            completionHandler(item,nil)
        } catch let e {
            completionHandler(nil, .cantUpdate(e.localizedDescription))
        }
    }
    
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        fatalError()
    }
    
    func findWithFriend(id: String, completion: @escaping (Conversation?, StoreError?) -> Void ){
        print("find conv with friend: \(id)")
        let query = table.filter(members == id)
        
        do {
            let result : [ConversationSQLite] = try db.prepare(query).map{ row in
                return try row.decode()
            }
            completion(result.first, nil)
        } catch let e{
            completion(nil,.cantFetch(e.localizedDescription))
        }
    }
    
    
}
