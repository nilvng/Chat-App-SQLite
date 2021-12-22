//
//  ConversationStoreAdapter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation

// converting models from and to UI format
// handle callback in main thread
class ConversationStoreWorker {
    
    var store : ConversationStore
    
    static var shared : ConversationStoreWorker!
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Conversation",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)

    
    init (store: ConversationSQLiteStore){
        self.store = store
    }
    
    static func getInstance(store : ConversationSQLiteStore? = nil) -> ConversationStoreWorker{
        if store == nil || shared != nil {
            return shared
        }
        shared = ConversationStoreWorker(store: store!)
        return shared
    }
    
    func getAll(noPages: Int, noRecords: Int ,completionHandler: @escaping ([ConversationsModel]?, StoreError?) -> Void) {
        utilityQueue.async {
            self.store.getAll(noRecords: noRecords, noPages: noPages, desc: true) { res, err in
                
                var items : [ConversationsModel]? = nil
                
                // post-process results -> convert into UI models
                if let fs = res{
                    items = fs.map{ self.toUIModel(conversation:$0)! }
                }
                
                DispatchQueue.main.async {
                    completionHandler(items,err)
                }
            }
        }
        
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (ConversationsModel?, StoreError?) -> Void) {
        fatalError()
    }

    func create(newItem: ConversationsModel, completionHandler: @escaping (ConversationsModel?, StoreError?) -> Void) {
        self.utilityQueue.async {
            // preprocess
            let item = self.toDtbModel(conversation: newItem)
            
            self.store.create(newItem: item!) { res, err in
                
                let uiItem = self.toUIModel(conversation: res)

                DispatchQueue.main.async {
                    completionHandler(uiItem,err)
                }
            }
        }

    }
    
    func update(item: ConversationsModel, completionHandler: @escaping (ConversationsModel?, StoreError?) -> Void) {
        self.utilityQueue.async {
            let dbItem = self.toDtbModel(conversation: item)

            self.store.update(item: dbItem!){ res, err in
                
                let uiItem = self.toUIModel(conversation: res)

                DispatchQueue.main.async {
                    completionHandler(uiItem,err)
                }
            }
        }
    }
    
    func delete(id: String, completionHandler: @escaping (ConversationsModel?, StoreError?) -> Void) {
        fatalError()
    }
    
    func findWithFriend(_ friend : Friend, completion: @escaping (ConversationsModel?, StoreError?) -> Void ){
        
        self.utilityQueue.async {

            self.store.findWithFriend(friend){ res, err in
                
                let uiItem = self.toUIModel(conversation: res)

                DispatchQueue.main.async {
                    completion(uiItem,err)
                }
            }
        }
    }
    
    func toUIModel(conversation: Conversation?) -> ConversationsModel?{
        guard let c = conversation else {
            return nil
        }
        return ConversationsModel(theme: c.theme, thumbnail: c.thumbnail, title: c.title, id: c.id, members: c.members, lastMsg: c.lastMsg, timestamp: c.timestamp)
    }
    
    func toDtbModel(conversation: ConversationsModel?) -> ConversationSQLite?{
        guard let c = conversation else {
            return nil
        }
        return ConversationSQLite(theme: c.theme, thumbnail: c.thumbnail, title: c.title, id: c.id, members: c.members, lastMsg: c.lastMsg, timestamp: c.timestamp)
    }
}
