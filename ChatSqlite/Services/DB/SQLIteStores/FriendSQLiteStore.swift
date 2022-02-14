//
//  FriendSQLiteStore.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import SQLite

class FriendSQLiteStore {
    var db : Connection?
    var table  = Table("Friend")
    let id = Expression<String>("id")
    let name = Expression<String>("name")
    let phoneNumber = Expression<String>("phoneNumber")
    let avatar = Expression<String?>("avatar")
    
    init(){
        getInstance(path: "chat-friend.sqlite")
    }
    
    func createTable(){
        do{
        try db?.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(phoneNumber)
            t.column(avatar)
        })
        } catch let e {
            print(e.localizedDescription)
        }
    }
    func getInstance(path subPath : String){
        let dirs: [NSString] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                               FileManager.SearchPathDomainMask.allDomainsMask, true) as [NSString]
        let dir = dirs[0]
                
        let path = dir.appendingPathComponent(subPath);
            
        do{
            db = try Connection(path)
            createTable()
        } catch let e{
            db = nil
            print(e.localizedDescription)
        }
        
    }
}

extension FriendSQLiteStore : FriendDBStore{    
    
    func getAll(completionHandler: @escaping ([Friend]?, StoreError?) -> Void){
        do {
            let result : [FriendSqlite] = try db!.prepare(table).map { row in
                return try row.decode()
            }
            completionHandler(result,nil)
        } catch let e{
            print(e.localizedDescription)
            completionHandler(nil,.cantFetch("Cant fetch"))
        }
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        let query = table.filter(self.id == id)
        
        
        do {
            let result : [FriendSqlite] = try db!.prepare(query).map { row in
                return try row.decode()
            }
            completionHandler(result.first, nil)
        } catch let e {
            print(e.localizedDescription)
            completionHandler(nil, .cantFetch("Can't fetch row with id \(id)"))
        }
    }
    
    func add(newItem: Friend, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        guard let item = newItem as? FriendSqlite else {
            completionHandler(nil, .cantFetch("Wrong type"))
            return
        }
        
        do {
            let rowid = try db?.run(table.insert(item))
            
            print("Create Friend row: \(String(describing: rowid))")
            completionHandler(newItem, nil)
        } catch let e {
            print("store failed: " + e.localizedDescription)
            completionHandler(nil,.cantCreate(e.localizedDescription))
        }
    }
    
    func update(item: Friend, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        guard let item = item as? FriendSqlite else {
            completionHandler(nil, .cantUpdate("wrong type"))
            return
        }
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        fatalError()
    }
    
    func generateId() -> String{
        return UUID().uuidString
    }
        
}
