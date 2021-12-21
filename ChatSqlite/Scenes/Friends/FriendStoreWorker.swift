//
//  FriendStoreWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/12/2021.
//

import Foundation

import Foundation

// converting models from and to UI format
// handle callback in main thread
class FriendStoreWorker {
    
    var store : FriendSQLiteStore
    
    static var shared : FriendStoreWorker!
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Friends",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    var initiatedQueue  = DispatchQueue(label: "zalo.chatApp.Friends",
                                        qos: .userInitiated,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    
    init (store: FriendSQLiteStore){
        self.store = store
    }
    
    static func getInstance(store : FriendSQLiteStore) -> FriendStoreWorker{
        if shared != nil {
            return shared
        }
        shared = FriendStoreWorker(store: store)
        return shared
    }
    
    func getAll(completionHandler: @escaping ([FriendsModel]?, StoreError?) -> Void) {
        utilityQueue.async {
            self.store.getAll { friends, err in
                
                var res : [FriendsModel]? = nil
                
                // post-process results -> convert into UI models
                if let fs = friends{
                    res = fs.map{ self.toUIModel(friend:$0)! }
                }
                
                DispatchQueue.main.async {
                    completionHandler(res,err)
                }
            }
        }
        
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (FriendsModel?, StoreError?) -> Void) {
        fatalError()
    }

    func create(newItem: FriendsModel, completionHandler: @escaping (FriendsModel?, StoreError?) -> Void) {
        self.utilityQueue.async {
            // preprocess
            let friend = self.toDtbModel(friend: newItem)
            
            self.store.create(newItem: friend!) { res, err in
                let f = self.toUIModel(friend: res)
                DispatchQueue.main.async {
                    completionHandler(f,err)
                }
            }
        }

    }
    
    func update(item: FriendsModel, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        fatalError()
    }
    
    func toUIModel(friend: FriendSqlite?) -> FriendsModel?{
        guard let f = friend else{
            return nil
        }
        return FriendsModel(avatar: f.avatar, id: f.id, phoneNumber: f.phoneNumber, name: f.name)
    }
    
    func toDtbModel(friend: FriendsModel?) -> FriendSqlite?{
        guard let f = friend else{
            return nil
        }
        return FriendSqlite(avatar: f.avatar, id: f.id, phoneNumber: f.phoneNumber, name: f.name)
    }
}
