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

class ConversationInteractor : ConversationsBusinessLogic{
    var store : ConversationStoreWorker
    weak var presenter : ConversationPresenter?
    var noRecords : Int = 13
    var currPage = 0
    var offset : CGFloat = 30
    
    init(store: ConversationStoreWorker){
        self.store = store
    }
    
    
    func fetchData(){
        store.getAll(noPages: 0, noRecords: noRecords, completionHandler: { [weak self] items, err in
            if let convs = items {
                self?.presenter?.presentAllItems(convs)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    func addItem(_ item : ConversationsModel){

        store.create(newItem: item, completionHandler: { [weak self] item, err in
            if let i = item {
                self?.presenter?.presentNewItems(i)
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
        
        store.getAll(noPages: pages, noRecords: noRecords) { [weak self] items, err in
            if items == nil || items!.isEmpty {return}
            self?.presenter?.presentAllItems(items)
            
        }
    }
    
}
