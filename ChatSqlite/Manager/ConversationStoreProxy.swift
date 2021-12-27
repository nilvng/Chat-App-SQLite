//
//  ConversationManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 24/12/2021.
//

import Foundation

protocol ConversationDataLogic {
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void)
    func add(newItem: Conversation, completionHandler: @escaping (Conversation?, StoreError?) -> Void)
    func delete(id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void)
    func update(item: Conversation,completionHandler : @escaping (Conversation?, StoreError?) -> Void)
    func findWithFriend(_ friend : Friend, completion: @escaping (Conversation?, StoreError?) -> Void )
}

class ConversationStoreProxy : ConversationDataLogic {
    
    var store : ConversationDataLogic = ConversationSQLiteStore()
    
    var items : [Conversation] = []
    
    static var shared = ConversationStoreProxy()
        
    var isDoneFetching : Bool = false
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Conversations",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    init (){
        print("Conversation Manager created.")
    }
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool = true, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void) {
        utilityQueue.async { [self] in
            
        // Find in cache
            let startIndex = noPages * noRecords
            let endIndex = startIndex + noRecords
            
            if startIndex > self.items.count && isDoneFetching {
                completionHandler(nil,.cantFetch("Exceed amount of Messages"))
                return
            }
            print("\(startIndex) - \(endIndex) : \(items.count)")

            if endIndex < items.count || self.isDoneFetching{
                print("Cached msgs.")
                let end = endIndex < self.items.count ? endIndex : items.count - 1
                
                DispatchQueue.main.async {

                completionHandler(Array(items[startIndex...end]), nil)

                }
                return
            }
            print("Fetch msgs.")

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
                
                DispatchQueue.main.async {

                    completionHandler(res,err)
                }
            })
        }
        
    }
    
    func findWithFriend(_ friend : Friend, completion: @escaping (Conversation?, StoreError?) -> Void ){
        
        self.utilityQueue.async {

            self.store.findWithFriend(friend){ res, err in
                
                DispatchQueue.main.async {
                    completion(res,err)
                }
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
            
            DispatchQueue.main.async {

                completionHandler(newItem,nil)
            
            }
            // Add to db
            store.add(newItem: newItem, completionHandler: { res, err in
                if err != nil{
                    DispatchQueue.main.async {

                        completionHandler(nil ,err)
                    }
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
            
            DispatchQueue.main.async {
                completionHandler(item,nil)
            }
            
            // in db
            self.store.update(item: item){ res, err in
                if err != nil {
                    DispatchQueue.main.async {
                        print("some error")
                        completionHandler(nil ,err)
                    }
                }
                
            }
        }
    }
    
    func delete(id: String, completionHandler: @escaping (Conversation?, StoreError?) -> Void) {
        fatalError()
    }
    
}
