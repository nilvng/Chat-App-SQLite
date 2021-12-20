//
//  ConversationInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation

protocol ConversationPresenter : AnyObject {
    func presentAllItems(_ items : [Conversation])
    func presentNewItems(_ item : Conversation)
}

class ConversationInteractor {
    var store = ConversationSQLiteStore.shared
    weak var presenter : ConversationPresenter?
    var noRecords : Int = 13
    var noPages = 0
    func fetchData(){
        store.getAll(noRecords: noRecords, noPages: noPages, completionHandler: { [weak self] items, err in
            if let friends = items {
                self?.presenter?.presentAllItems(friends)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    func createItem(_ item : Conversation){
        store.create(newItem: item, completionHandler: { [weak self] item, err in
            if let i = item {
                self?.presenter?.presentNewItems(i)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
}
