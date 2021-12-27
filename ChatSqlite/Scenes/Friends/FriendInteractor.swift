//
//  FriendInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation

protocol FriendPresenter {
    func presentItems(_ items : [FriendsModel])
    func presentNewItems(_ item : FriendsModel)
}

class FriendInteractor : FriendsDisplayLogic{
    var store : FriendStoreWorker
    var presenter : FriendPresenter? = nil
    
    init( store : FriendSQLiteStore ){
        self.store = FriendStoreWorker.getInstance(store: store)
    }
    
    func fetchData(){
        store.getAll(completionHandler: { [weak self] items, err in
            if let friends = items{
                self?.presenter?.presentItems(friends)
            } else {
                print(err?.localizedDescription ?? "null error")
            }
        })
    }
    
    func addItem(_ item: FriendsModel){
        store.create(newItem: item, completionHandler: {[weak self] item, err in
            if let i = item , err == nil{
                self?.presenter?.presentNewItems(i)
            } else {
                print(err?.localizedDescription ?? "null error")
            }
        })
    }
}
