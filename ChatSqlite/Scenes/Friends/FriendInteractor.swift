//
//  FriendInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation

class FriendInteractor {
    let store  = FriendSQLiteStore()
    var presenter : FriendPresenter? = nil
    
    func getAll(){
        store.getAll(completionHandler: { [weak self] items, err in
            if let friends = items {
                self?.presenter?.presentItems(friends)
            } else {
                print(err?.localizedDescription ?? "null error")
            }
        })
    }
    
    func addItem(_ item: Friend){
        
        store.create(newItem: item, completionHandler: {[weak self] item, err in
            if let friend = item {
                self?.presenter?.presentNewItems(friend)
            } else {
                print(err?.localizedDescription ?? "null error")
            }
        })
    }
}
