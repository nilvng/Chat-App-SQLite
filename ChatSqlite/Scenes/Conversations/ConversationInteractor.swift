//
//  ConversationInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation

protocol ConversationPresenter : AnyObject {
    func presentAllItems(_ items : [ConversationsModel])
    func presentNewItems(_ item : ConversationsModel)
}

class ConversationInteractor {
    var store : ConversationStoreWorker
    weak var presenter : ConversationPresenter?
    var noRecords : Int = 13
    var noPages = 0
    
    init(store: ConversationStoreWorker){
        self.store = store
    }
    
    
    func fetchData(){
        store.getAll(noPages: noPages, noRecords: noRecords, completionHandler: { [weak self] items, err in
            if let convs = items {
                self?.presenter?.presentAllItems(convs)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    func createItem(_ item : ConversationsModel){

        store.create(newItem: item, completionHandler: { [weak self] item, err in
            if let i = item {
                self?.presenter?.presentNewItems(i)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    
}
