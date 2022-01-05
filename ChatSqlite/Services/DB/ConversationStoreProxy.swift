//
//  ConversationManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 24/12/2021.
//

import Foundation
// MARK: DataLogic protocol
protocol ConversationDataLogic {
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void)
    func add(newItem: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void)
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void)
    func update(item: Conversation,completionHandler : @escaping (Conversation?, StoreError?) -> Void)
    func findWithFriend(id : String, completion: @escaping (Conversation?, StoreError?) -> Void )
}

// MARK: Proxy Class
class ConversationStoreProxy {
    var store : ConversationDataLogic = ConversationSQLiteStore()
    
    var items : [Conversation] = []
    
    static var shared = ConversationStoreProxy()
        
    var isDoneFetching : Bool = false
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Conversations",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    private init (){
        print("Conversation Manager created.")
    }
}

// MARK: ConversationService
extension ConversationStoreProxy : ConversationService {
    
    func fetchAllItems(noRecords: Int, noPages: Int, desc: Bool, completionHandler: @escaping ([ConversationDomain]?, StoreError?) -> Void) {
        
        self.getAll(noRecords: noRecords, noPages: noPages, completionHandler: { res, err in
            if let items = res {
                let mappedItems = items.map { $0.toUIModel() }
                completionHandler(mappedItems, err)
            } else {
                completionHandler(nil,err)
            }
        })
    }
    
    func fetchItemWithId(_ id: String, completionHandler: @escaping (ConversationDomain?, StoreError?) -> Void) {
        self.getWithId(id, completionHandler: { res, err in
            if let item = res {
                let mappedItems = item.toUIModel()
                completionHandler(mappedItems, err)
            } else {
                completionHandler(nil, err)
            }
        })
    }
    
    func updateItem(_ item: ConversationDomain, completionHandler: @escaping (StoreError?) -> Void) {
        let mappedItem = toDtbModel(item)
        self.update(item: mappedItem, completionHandler: { res, err in

                completionHandler(err)
        
        })
    }
    
    func deleteItem(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        self.delete(id: id, completionHandler: completionHandler)
    }
    
    func createItem(_ item: ConversationDomain, completionHandler: @escaping (StoreError?) -> Void) {
        let mappedItem = toDtbModel(item)
        self.add(newItem: mappedItem, completionHandler: { res, err in

                completionHandler(err)
            
        })
    }

    func findItemWithFriend(id: String, completion: @escaping (ConversationDomain?, StoreError?) -> Void) {
        self.findWithFriend(id: id, completion: { res, err in
            if let resItem = res {
                completion(self.toUIModel(resItem), err)
            } else {
                completion(nil, err)
            }
        })
    }
    func toDtbModel(_ conversation: ConversationDomain) -> Conversation{
        var c =  ConversationSQLite()
        c.fromUIModel(c: conversation)
        return c
    }
    func toUIModel(_ conversation: Conversation) -> ConversationDomain{
        return conversation.toUIModel()
    }
    
}

// MARK: ConversationDataLogic: queue
extension ConversationStoreProxy : ConversationDataLogic {
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool = true, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void) {
        utilityQueue.async { [self] in
            
        // Find in cache
            let startIndex = noPages * noRecords
            let endIndex = startIndex + noRecords
            
            if startIndex > self.items.count && isDoneFetching {
                completionHandler(nil,.cantFetch("Exceed amount of Conversation"))
                return
            }
            print("\(startIndex) - \(endIndex) : \(items.count)")

            if endIndex < items.count || self.isDoneFetching{
                print("Cached convs.")
                let end = endIndex < self.items.count ? endIndex : items.count - 1
                
                if (startIndex <= end){
                completionHandler(Array(items[startIndex...end]), nil)
                }
                return
            }
            print("Fetch convs.")

            // Fetch in db
            store.getAll(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: { res, err in
                
                if (res != nil){
                    if (res!.isEmpty) {
                    self.isDoneFetching =  true
                    
                    } else {
                        if res!.count < noRecords {
                            self.isDoneFetching = true
                        }
                        self.items += res!
                    }
                }
                    completionHandler(res,err)
                })
        }
        
    }
    
    func findWithFriend(id : String, completion: @escaping (Conversation?, StoreError?) -> Void ){
        
        self.utilityQueue.async {

            self.store.findWithFriend(id: id){ res, err in
                
                    completion(res,err)

            }
        }
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
    func add(newItem: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        utilityQueue.async { [self] in
            
            // Add in cache
            print("Worker add msg.")
            items.append(newItem)
            
                completionHandler(newItem,nil)
            
            // Add to db
            store.add(newItem: newItem, completionHandler: { res, err in
                if err != nil{
                        completionHandler(nil ,err)
                }
            })
        }
    }
    
    func update(item: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        self.utilityQueue.async { [self] in
            
            // in memo
            guard let  prev = items.firstIndex(where: {$0.id == item.id}) else {
                completionHandler(nil, .cantUpdate("Cant update Conversation in memo."))
                return
            }
            
            items[prev] = item
            items.sort(by: {$0.timestamp > $1.timestamp})
            
            completionHandler(item,nil)
            
            // in db
            self.store.update(item: item){ res, err in
                if err != nil {
                        print("some error")
                        completionHandler(nil ,err)
                }
                
            }
        }
    }
    
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        utilityQueue.async {
        // delete in memo
            if let deleteIndex = self.items.firstIndex(where: {$0.id == id } ){
                self.items.remove(at: deleteIndex)
            }
            print("after deleting conv: \(self.items)")
        // delete in db
            self.store.delete(id: id, completionHandler: completionHandler)
        }
    }
    
}
