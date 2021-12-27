//
//  MessengesSQLStore.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import SQLite

class MessagesSQLStore : MessageDataLogic {
    var conversationID: String
    
    
    var db : Connection?
    
    var table = Table("Messages")
    var cid = Expression<String>("cid")
    var content = Expression<String>("content")
    var timestamp = Expression<Date>("timestamp")
    var type = Expression<String>("type")
    var sender = Expression<String>("sender")
    
        
    let serialQueue = DispatchQueue(
        label: "zalo.chatApp.messagesStore",
        qos: .userInitiated,
        autoreleaseFrequency: .workItem,
        target: nil)
    
    init(){
        conversationID = "" // testing only
        getInstance(path: "chat-message.sqlite")
        createTable()
        
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
    
}
extension MessagesSQLStore{

    
    func getAll(noRecords : Int, noPages: Int, desc : Bool = false, completionHandler: @escaping ([Message]?, StoreError?) -> Void) {
            
        do {
            var queries = table.filter(cid == conversationID)
                .limit(noRecords, offset: noRecords * noPages)
            
            queries = desc ? queries.order(timestamp.desc) : queries.order(timestamp.asc)
            
            let result : [MessageSQLite] = try db!.prepare(queries).map { row in
                return try row.decode()
            }
            completionHandler(result,nil)
        } catch let e{
            print(e.localizedDescription)
            completionHandler(nil,.cantFetch("Cant fetch"))
            }
        }
        
    
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func add(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        
        guard let item = newItem as? MessageSQLite else {
            completionHandler(nil, .cantFetch("wrong type"))
            return
        }
        
        do {
            let rowid = try db?.run(table.insert(item))
            
            print("Create Messenge row: \(String(describing: rowid))")
            completionHandler(newItem, nil)
        } catch let e {
            print("store failed: " + e.localizedDescription)
            completionHandler(nil,.cantCreate(e.localizedDescription))
        }
    }
    
    func update(item: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        guard let item = item as? MessageSQLite else {
            completionHandler(nil, .cantFetch("wrong type"))
            return
        }
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    
}
