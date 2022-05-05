//
//  FriendInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation

protocol FriendPresenter {
    func presentItems(_ items : [FriendDomain])
    func presentNewItems(_ item : FriendDomain)
}

class FriendMediator : FriendDBMediator{
    var store : FriendService
    var presenter : FriendPresenter? = nil
    
    init(){
        self.store = NativeContactStoreAdapter.shared
    }
    
    func fetchData(){
        store.fetchAllItems(completionHandler: { [weak self] items, err in
            if let friends = items{
                self?.presenter?.presentItems(friends)
            } else {
                print(err?.localizedDescription ?? "null error")
            }
        })
    }
    
    func addItem(_ item: FriendDomain){
        store.createItem(item, completionHandler: {err in
            if err != nil{
                print(err!.localizedDescription)
            }
        })
    }
}
