//
//  StoreAPIs.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
protocol StoreAPIs {
    associatedtype T
     
    func getAll(completionHandler : @escaping ([T]?, StoreError?) -> Void)
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
