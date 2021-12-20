//
//  MessengesSQLStore.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import SQLite

class MessagesSQLStore {
    
    var db : Connection?
    var items : [Message] = []
    
    var table = Table("Messages")
    var cid = Expression<String>("cid")
    var content = Expression<String>("content")
    var timestamp = Expression<Date>("timestamp")
    var type = Expression<String>("type")
    var sender = Expression<String>("sender")
    
    init(){
        getInstance(path: "chat-message.sqlite")
        createTable()
        
    }
    
    func getAll(conversationID: String, noRecords : Int, noPages: Int, desc : Bool = true, completionHandler: @escaping ([Message]?, StoreError?) -> Void) {
        print(conversationID)
        do {
            let queries = table.filter(cid == conversationID)
                .order(timestamp.desc)
                .limit(noRecords, offset: noRecords * noPages)
            
            let result : [MessageSQLite] = try db!.prepare(queries).map { row in
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
            t.column(cid)
            t.column(content)
            t.column(timestamp)
            t.column(sender)
            t.column(type)
        })
        } catch let e {
            print(e.localizedDescription)
        }
    }

    
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func create(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        do {
            guard let sqliteObject = newItem as? MessageSQLite else {
                completionHandler(nil, .cantFetch("SQLite Error: Cannot add non-SQLite object"))
                return
            }
            let rowid = try db?.run(table.insert(sqliteObject))
            
            print("Create Messenge row: \(String(describing: rowid))")
            completionHandler(newItem, nil)
        } catch let e {
            print("store failed: " + e.localizedDescription)
            completionHandler(nil,.cantCreate(e.localizedDescription))
        }
    }
    
    func update(item: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    
}
