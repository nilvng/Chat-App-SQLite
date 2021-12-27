//
//  MessageStoreWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/12/2021.
//

import Foundation

protocol MessageDataLogic {
    
    var conversationID : String { get set}
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool, completionHandler: @escaping ([Message]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void)
    func add(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void)
    func delete(id: String, completionHandler: @escaping (Message?, StoreError?) -> Void)

}

// handle callback in main thread
class MessageStoreProxy : MessageDataLogic {

    var store : MessageDataLogic = MessagesSQLStore()
    
    var messages : [Message] = []
    
    var conversationID : String
    
    var isDoneFetching : Bool = false
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Messages",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    init (cid : String){
        print("worker created.")
        self.conversationID = cid
        store.conversationID = cid
    }
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool = false, completionHandler: @escaping ([Message]?, StoreError?) -> Void) {
        utilityQueue.async { [self] in
            
        // Find in cache
            let startIndex = noPages * noRecords
            let endIndex = startIndex + noRecords
            
            if startIndex > self.messages.count && isDoneFetching {
                print("warning: fetch nonsense index: \(startIndex) from conv: \(conversationID)")
                completionHandler(nil,.cantFetch("Exceed amount of Messages"))
                return
            }
            print("\(startIndex) - \(endIndex) : \(messages.count)")

            if endIndex < messages.count || self.isDoneFetching{
                print("Cached msgs.")
                let end = endIndex < self.messages.count ? endIndex : messages.count - 1

                DispatchQueue.main.async {
                    completionHandler(Array(messages[startIndex...end]), nil)
                }
                return
            }
            print("Fetch msgs.")

            // Fetch in db
            store.getAll(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: { res, err in
                
                if (res != nil){
                    if (res!.isEmpty) {
                        self.isDoneFetching =  true
                        DispatchQueue.main.async {
                            completionHandler(res,err)
                        }
                    } else {
                        if res!.count < noRecords {
                            self.isDoneFetching = true
                        }
                        self.messages += res!
                    }
                }
                DispatchQueue.main.async {
                    completionHandler(res,err)
                }
            })
        }
        
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func add(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        utilityQueue.async { [self] in
            
            // Add in cache
            print("Worker add msg.")
            messages.append(newItem)
            
            DispatchQueue.main.async {
                completionHandler(newItem,nil)
            }
            
            // Add to db
            store.add(newItem: newItem, completionHandler: { res, err in
                if err != nil { // there is error
                    completionHandler(res,err)
                }
            })
        }
    }
    
    func update(item: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func delete(id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
}
