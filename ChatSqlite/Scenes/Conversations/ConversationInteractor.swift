//
//  ConversationInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import Foundation
import UIKit

protocol ConversationPresenter : AnyObject {
    func presentAllItems(_ items : [ConversationDomain]?)
    func presentNewItems(_ item : ConversationDomain)
}

class ConversationInteractor : ConversationsDisplayLogic{
    var store : ConversationService
    weak var presenter : ConversationPresenter?
    var noRecords : Int = 20
    var currPage = 0
    var offset : CGFloat = 300
    
    init(store: ConversationService){
        self.store = store
    }
    
    
    func fetchData(){
        store.fetchAllItems(noRecords: noRecords, noPages: 0, desc: true, completionHandler: { [weak self] res, err in
            if let convs = res {
                self?.presenter?.presentAllItems(convs)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    func addItem(_ item : ConversationDomain){
        // map to db model
        store.createItem(item, completionHandler: { err in

                print(err?.localizedDescription ?? "")
            
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
        
        store.fetchAllItems(noRecords: noRecords, noPages: pages, desc: true) { [weak self] res, err in
            if res == nil || res!.isEmpty {
                print("empty fetch!")
                return}
            
            self?.presenter?.presentAllItems(res!)
            
        }
    }

}
