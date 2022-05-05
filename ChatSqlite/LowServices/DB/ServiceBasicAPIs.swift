//
//  StoreAPIs.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
protocol ServiceBasicAPIs {
    associatedtype T
    
    func getWithId(_ id: String, completionHandler : @escaping (T?, StoreError?) -> Void)
    func create(newItem: T,completionHandler : @escaping (T?, StoreError?) -> Void)
    func update(item: T,completionHandler : @escaping (T?, StoreError?) -> Void)
    func delete(id: String ,completionHandler : @escaping (T?, StoreError?) -> Void)
}


enum StoreError : Error, Equatable{
    case cantFetch(String)
    case cantCreate(String)
    case cantUpdate(String)
    case cantDelete(String)
    case doneFetching(String)
}

protocol ConversationService{
    func fetchAllItems(noRecords: Int, noPages: Int, desc : Bool, completionHandler: @escaping ([ConversationDomain]?, StoreError?) -> Void)
    func fetchItemWithId(_ id: String, completionHandler : @escaping (ConversationDomain?, StoreError?) -> Void)
    func createItem(_ item: ConversationDomain,completionHandler : @escaping (StoreError?) -> Void)
    func upsertItem(_ item: ConversationDomain,completionHandler : @escaping (StoreError?) -> Void)
    func updateItem(_ item: ConversationDomain,completionHandler : @escaping (StoreError?) -> Void)
    func deleteItem(id: String ,completionHandler : @escaping (StoreError?) -> Void)
    func findItemWithFriend(id : String, completion: @escaping (ConversationDomain?, StoreError?) -> Void )
    func filterBy(key: String, completion: @escaping ([ConversationDomain]?, StoreError?) -> Void )
}

protocol FriendService{
    func fetchAllItems(completionHandler: @escaping ([FriendDomain]?, StoreError?) -> Void)
    func fetchItemWithId(_ id: String, completionHandler : @escaping (FriendDomain?, StoreError?) -> Void)
    func createItem(_ item: FriendDomain,completionHandler : @escaping (StoreError?) -> Void)
    func updateItem(_ item: FriendDomain,completionHandler : @escaping (StoreError?) -> Void)
    func deleteItem(id: String ,completionHandler : @escaping (StoreError?) -> Void)
}

protocol MessageDBService{
    func fetchAllItems(noRecords: Int, noPages: Int, desc : Bool, completionHandler: @escaping ([MessageDomain]?, StoreError?) -> Void)
    func fetchItemWithId(_ id: String, completionHandler : @escaping (MessageDomain?, StoreError?) -> Void)
    func createItem(_ item: MessageDomain,completionHandler : @escaping (StoreError?) -> Void)
    func updateItem(_ item: MessageDomain,completionHandler : @escaping (StoreError?) -> Void)
    func updateStatus(id: String, status: MessageStatus, completionHandler : @escaping (StoreError?) -> Void)
    func deleteItem(id: String ,completionHandler : @escaping (StoreError?) -> Void)
    func deleteAllItems(completionHandler: @escaping (StoreError?) -> Void)
    func ffUpdateStatus(completionHandler: @escaping (StoreError?) -> Void)
}
