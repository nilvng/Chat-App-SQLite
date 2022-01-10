//
//  MessageStoreWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 21/12/2021.
//

import Foundation

// MARK: DataLogic Protocol
protocol MessageDataLogic {
    
    var conversationID : String { get set}
    
    func getAll( noRecords : Int, noPages: Int, desc : Bool, completionHandler: @escaping ([Message]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void)
    func add(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void)
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void)
    func deleteAllMessages(completion: @escaping (StoreError?) -> Void)
}
class MessageStoreProxy{
    
    var store : MessageDataLogic = MessagesSQLStore()
    
    var messages : [Message] = []
    
    var conversationID : String
    
    var isDoneFetching : Bool = false
    
    var utilityQueue  = DispatchQueue(label: "zalo.chatApp.Messages",
                                      qos: .utility,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    init (cid : String){
        self.conversationID = cid
        store.conversationID = cid
    }

}
// MARK: MessageService
extension MessageStoreProxy : MessageService {
    func fetchAllItems(noRecords: Int, noPages: Int, desc: Bool, completionHandler: @escaping ([MessageDomain]?, StoreError?) -> Void) {
        self.getAll(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: { res, err in
            if let resItems = res {
                let mapped = resItems.map { self.toUIModel(item: $0)}
                completionHandler(mapped, err)
            } else {
                completionHandler(nil, err)
            }
        })
    }
    
    func fetchItemWithId(_ id: String, completionHandler: @escaping (MessageDomain?, StoreError?) -> Void) {
        self.getWithId(id, completionHandler:  { res, err in
            if let resItem = res {
                let mapped = self.toUIModel(item: resItem)
                completionHandler(mapped, err)
            } else {
                completionHandler(nil, err)
            }
        })
    }
    
    func createItem(_ item: MessageDomain, completionHandler: @escaping (StoreError?) -> Void) {
        let mapped = toDtbModel(item: item)
        self.add(newItem: mapped, completionHandler:  { res, err in

                completionHandler(err)
            
        })

    }
    
    func updateItem(_ item: MessageDomain, completionHandler: @escaping (StoreError?) -> Void) {
        let mapped = toDtbModel(item: item)
        self.update(item: mapped, completionHandler:  { res, err in
        
                completionHandler(err)
        })
    }
    
    func deleteItem(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        self.delete(id: id, completionHandler: completionHandler)
    }
    
    func deleteAllItems(completionHandler: @escaping (StoreError?) -> Void) {
        self.deleteAllMessages(completion: completionHandler)
    }
    func toUIModel(item f: Message) -> MessageDomain{
        return f.toUIModel()
    }
    
    func toDtbModel(item f: MessageDomain) -> Message{
        var msg  = MessageSQLite()
        msg.fromUIModel(c: f)
        return msg
    }
    
}

// MARK: StoreProxy
extension MessageStoreProxy : MessageDataLogic {
    
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
            print("Proxy: \(startIndex) - \(endIndex) : \(messages.count) - done? \(isDoneFetching)")

            if self.isDoneFetching{
                print("Proxy: Cached msgs.")
                let end = endIndex < self.messages.count ? endIndex : messages.count - 1
                print("Proxy start: \(startIndex) - end: \(end)")

                if (startIndex <= end){
                    completionHandler(Array(messages[startIndex...end]), nil)
                }
                return
            }
            print("Proxy: Fetch msgs.")

            // Fetch in db
            store.getAll(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: { res, err in
                
                if (res != nil){
                    if (res!.isEmpty) {
                        self.isDoneFetching =  true
                        completionHandler(res,err)
                    } else {
                        if res!.count < noRecords {
                            self.isDoneFetching = true
                        }
                        self.messages += res!
                    }
                }
                    completionHandler(res,err)
            })
        }
        
    }
    
    func getWithId(_ id: String, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        fatalError()
    }
    
    func add(newItem: Message, completionHandler: @escaping (Message?, StoreError?) -> Void) {
        utilityQueue.async { [self] in
            
            // Add in cache
            print("Proxy: add msg.")
            messages.insert(newItem, at: 0)
            
                completionHandler(newItem,nil)
                
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
    
    func delete(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        fatalError()
    }
    func deleteAllMessages(completion: @escaping (StoreError?) -> Void) {
        utilityQueue.async {
            self.messages = []
            
            self.store.deleteAllMessages{ err in
                print(err?.localizedDescription ?? "success delete all msg with cid: \(self.conversationID)")
            }
        }
    }
}
