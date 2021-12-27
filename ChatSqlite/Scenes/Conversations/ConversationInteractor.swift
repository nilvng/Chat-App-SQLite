//
//  ConversationInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import UIKit

protocol ConversationPresenter : AnyObject {
    func presentAllItems(_ items : [ConversationsModel]?)
    func presentNewItems(_ item : ConversationsModel)
}

class ConversationInteractor : ConversationsDisplayLogic{
    var store : ConversationDataLogic
    weak var presenter : ConversationPresenter?
    var noRecords : Int = 20
    var currPage = 0
    var offset : CGFloat = 300
    
    init(store: ConversationDataLogic){
        self.store = store
    }
    
    
    func fetchData(){
        store.getAll(noRecords: noRecords, noPages: 0, desc: true, completionHandler: { [weak self] res, err in
            if let convs = res {
                
                // Convert into data model
                let items = convs.map { $0.toUIModel() }
                
                self?.presenter?.presentAllItems(items)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    func addItem(_ item : ConversationsModel){
        // map to db model
        let i = toDtbModel(item)
        store.add(newItem: i, completionHandler: { [weak self] item, err in
            if let i = item {
                self?.presenter?.presentNewItems(i.toUIModel())
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    
    func onScroll(tableOffset : CGFloat){
        print(tableOffset)
        let pages = Int(tableOffset / offset)
        print(pages)
        guard pages - currPage >= 1 else {
            return
        }
        currPage = pages
        
        store.getAll(noRecords: noRecords, noPages: pages, desc: true) { [weak self] res, err in
            if res == nil || res!.isEmpty {
                print("empty fetch!")
                return}
            
            let items = res!.map { $0.toUIModel() }

            self?.presenter?.presentAllItems(items)
            
        }
    }
    func toDtbModel(_ conversation: ConversationsModel) -> Conversation{
        var c =  ConversationSQLite()
        c.fromUIModel(c: conversation)
        return c
    }
}
