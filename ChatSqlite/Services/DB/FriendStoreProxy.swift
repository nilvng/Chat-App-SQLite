//
//  FriendStoreProxy.swift
//  ChatSqlite
//
//  Created by LAP11353 on 27/12/2021.
//

import Foundation

protocol DatabaseStore {
    associatedtype T
    
    func getAll(completionHandler: @escaping ([T]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler: @escaping (T?, StoreError?) -> Void)
    func add(newItem: T, completionHandler: @escaping (T?, StoreError?) -> Void)
    func update(item: T, completionHandler: @escaping (T?, StoreError?) -> Void)
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void)
}

protocol FriendDBStore{
    func getAll(completionHandler: @escaping ([Friend]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler: @escaping (Friend?, StoreError?) -> Void)
    func add(newItem: Friend, completionHandler: @escaping (Friend?, StoreError?) -> Void)
    func update(item: Friend, completionHandler: @escaping (Friend?, StoreError?) -> Void)
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void)
}

class FriendStoreProxy {
    let store : FriendDBStore = FriendSQLiteStore()
    
    var items : [Friend] = []
    
    static var shared = FriendStoreProxy()
        
    var isDoneFetching : Bool = false
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Friends",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    private init (){
        print("FriendService created.")
    }
}

extension FriendStoreProxy : FriendService {
    
    func fetchAllItems(completionHandler: @escaping ([FriendDomain]?, StoreError?) -> Void) {
        self.getAll(completionHandler: { res, err in
            if let resItems = res {
                let mapped = resItems.map { self.toUIModel(friend: $0)}
                completionHandler(mapped, err)
            } else {
                completionHandler(nil, err)
            }
        })
    }
    
    func fetchItemWithId(_ id: String, completionHandler: @escaping (FriendDomain?, StoreError?) -> Void) {
        self.getWithId(id){ res, err in
            if let item = res {
                let mapped = self.toUIModel(friend: item)
                completionHandler(mapped, err)
            } else {
                completionHandler(nil,err)
            }
        }
    }
    
    func createItem(_ item: FriendDomain, completionHandler: @escaping (StoreError?) -> Void) {
        let mapped = toDtbModel(friend: item)
        self.add(newItem: mapped, completionHandler: { res, err in
                completionHandler(err)
        })
    }
    
    func updateItem(_ item: FriendDomain, completionHandler: @escaping (StoreError?) -> Void) {
        let mapped = toDtbModel(friend: item)
        self.update(item: mapped, completionHandler: { res, err in

                completionHandler(err)
                
        })
    }
    
    func deleteItem(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        self.delete(id: id, completionHandler: completionHandler)
    }
    
    
    
    func toUIModel(friend f: Friend) -> FriendDomain{
        return FriendDomain(id: f.id, phoneNumber: f.phoneNumber, name: f.name, avatar: f.avatar)
    }
    
    func toDtbModel(friend f: FriendDomain) -> Friend{
        return FriendSqlite(avatar: f.avatar, id: f.id, phoneNumber: f.phoneNumber, name: f.name)
    }
}

extension FriendStoreProxy : FriendDBStore {
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        // find and delete in items
        
        // delete in db
        self.store.delete(id: id, completionHandler: completionHandler)
    }
    func getAll(completionHandler: @escaping ([Friend]?, StoreError?) -> Void) {
        self.utilityQueue.async { [self] in

        if !self.items.isEmpty{
            DispatchQueue.main.async {
            completionHandler(items, nil)
            }
        } else{
            self.store.getAll(completionHandler: {res, err in
                DispatchQueue.main.async {
                completionHandler(res, err)
                }
            })
        }
        }
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        self.utilityQueue.async { [self] in
        if let i = items.first(where: { $0.id == id}){
            DispatchQueue.main.async {
            completionHandler(i, nil)
            }
        } else {
            self.store.getWithId(id, completionHandler: {res, err in
                DispatchQueue.main.async {
                    completionHandler(res, err)
                }
            })
        }
        }
    }
    
    func add(newItem: Friend, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        self.utilityQueue.async {
            // preprocess
            self.store.add(newItem: newItem) { res, err in
                DispatchQueue.main.async {
                    completionHandler(res,err)
                }
            }
        }
    }
    
    func update(item: Friend, completionHandler: @escaping (Friend?, StoreError?) -> Void) {
        fatalError()
    }
    
}
