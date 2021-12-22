//
//  StoreAPIs.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
protocol StoreAPIs {
    associatedtype T
    
    func getWithId(_ id: String, completionHandler : @escaping (T?, StoreError?) -> Void)
    func create(newItem: T,completionHandler : @escaping (T?, StoreError?) -> Void)
    func update(item: T,completionHandler : @escaping (T?, StoreError?) -> Void)
    func delete(id: String ,completionHandler : @escaping (T?, StoreError?) -> Void)
}


enum StoreError : Error{
    case cantFetch(String)
    case cantCreate(String)
    case cantUpdate(String)
    case cantDelete(String)
}

protocol ConversationStore{
    func getAll(noRecords: Int, noPages: Int, desc : Bool, completionHandler: @escaping ([Conversation]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler : @escaping (Conversation?, StoreError?) -> Void)
    func create(newItem: Conversation,completionHandler : @escaping (Conversation?, StoreError?) -> Void)
    func update(item: Conversation,completionHandler : @escaping (Conversation?, StoreError?) -> Void)
    func delete(id: String ,completionHandler : @escaping (Conversation?, StoreError?) -> Void)
    func findWithFriend(_ friend : Friend, completion: @escaping (Conversation?, StoreError?) -> Void )
}

protocol FriendStore{
    func getAll(completionHandler: @escaping ([Friend]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler : @escaping (Friend?, StoreError?) -> Void)
    func create(newItem: Friend,completionHandler : @escaping (Friend?, StoreError?) -> Void)
    func update(item: Friend,completionHandler : @escaping (Friend?, StoreError?) -> Void)
    func delete(id: String ,completionHandler : @escaping (Friend?, StoreError?) -> Void)
}

protocol MessageStore{
    func getAll(conversationID: String, noRecords: Int, noPages: Int, desc : Bool, completionHandler: @escaping ([Message]?, StoreError?) -> Void)
    func getWithId(_ id: String, completionHandler : @escaping (Message?, StoreError?) -> Void)
    func create(newItem: Message,completionHandler : @escaping (Message?, StoreError?) -> Void)
    func update(item: Message,completionHandler : @escaping (Message?, StoreError?) -> Void)
    func delete(id: String ,completionHandler : @escaping (Message?, StoreError?) -> Void)
}
