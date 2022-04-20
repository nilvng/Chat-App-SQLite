//
//  MessengesSQLStore.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import SQLite

class MessagesSQLStore : MessageDBLogic {

    
    var conversationID: String
    
    
    var db : Connection?
    
    var table = Table("Messages")
    var mid = Expression<String>("mid")
    var cid = Expression<String>("cid")
    var content = Expression<String>("content")
    var timestamp = Expression<Date>("timestamp")
    var type = Expression<Int>("type")
    var sender = Expression<String>("sender")
    var downloaded = Expression<Bool>("downloaded")
    var status = Expression<Int?>("status")
    var mediaPreps = Expression<String?>("mediaPreps")

    
        
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
            t.column(mid, primaryKey: true)
            t.column(cid)
            t.column(content)
            t.column(timestamp)
            t.column(sender)
            t.column(type)
            t.column(downloaded)
            t.column(status)
            t.column(mediaPreps)
        })
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
}
extension MessagesSQLStore{
    
    func ffUpdateStatus(completionHandler: @escaping (StoreError?) -> Void){
        do {
            let item = table.filter(self.status != MessageStatus.seen.rawValue)
            try db?.run(item.update(self.status <- MessageStatus.seen.rawValue))
        } catch let e {
            print("\(self) update failed: \(e)")
        }
    }

    func updateStatus(id: String, status: MessageStatus, completionHandler: @escaping (StoreError?) -> Void) {
        do {
            let item = table.filter(mid == id)
            try db?.run(item.update(self.status <- status.rawValue))
        } catch let e {
            print("\(self) update failed: \(e)")
        }
    }
    
    func getAll(noRecords : Int, noPages: Int, desc : Bool = false, completionHandler: @escaping ([Message]?, StoreError?) -> Void) {
            
        do {
            var queries = table.filter(cid == conversationID)
                .limit(noRecords, offset: noRecords * noPages)
            //print("offset: \(noRecords * noPages) - pages: \(noPages)")
            queries = desc ? queries.order(timestamp.desc) : queries.order(timestamp.asc)
            let result : [MessageSQLite] = try db!.prepareRowIterator(queries).map { row in
                var m = MessageSQLite()
                m.mid = row[mid]
                m.cid = row[cid]
                m.content = row[content]
                m.type = MessageType(rawValue:row[type])
                m.timestamp = row[timestamp]
                m.sender = row[sender]
                m.downloaded = row[downloaded]
                if let rowData = row[mediaPreps] {
//                    print("did it")
                    do {
                        m.mediaPreps = rowData.parse(to: [MediaPrep].self)
                    } catch {
                        print("Cant parse mediaPreps")
                    }
                }
                if let val = row[status] {
                    m.status = MessageStatus(rawValue: val) ?? .seen
                } else {
                    m.status = .seen
                }
                return m
            }
//            let result: [MessageSQLite] = try db!.prepare(queries).map { row in
//                return try row.decode()
//            }
            completionHandler(result,nil)
        } catch let e{
            print(e)
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
    
    func update(item: Message, completionHandler: @escaping (StoreError?) -> Void) {
        guard let item = item as? MessageSQLite else {
            completionHandler(.cantFetch("wrong type"))
            return
        }
        do {
        try table.update(item)
            completionHandler(nil)
        }catch let e {
            completionHandler(.cantUpdate("Cant update message: \(mid)"))
        }
    }
    
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        fatalError()
    }
    
    func deleteAllMessages(completion: @escaping (StoreError?) -> Void) {
        let query = table.filter(cid == conversationID)
        do {
            try db?.run(query.delete())
            completion(nil)
        } catch {
            completion(.cantDelete("cant delete all msgs by cid: \(conversationID)"))
        }
    }
}
