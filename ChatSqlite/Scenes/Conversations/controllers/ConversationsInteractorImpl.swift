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
    func presentDeleteItem(_ item: ConversationDomain, at: IndexPath)
    func presentFilteredItems(_ items: [ConversationDomain]?)
}

class ConversationsInteractorImpl : ConversationListInteractor{
 
    
    weak var presenter : ConversationPresenter?
    var localStore : ConversationLocalLogic
    
    var noRecords : Int = 20
    var currPage = 0
    var offset : CGFloat = 300
    
    init(){
        self.localStore = SQLiteManager.shared
    }
    
    func filterBy(key: String) {
        localStore.filterConversation(by: key) { [weak self] items, err in
            guard let items = items, items.count > 0 else {
                print("filter return nothing")
                return
            }
            self?.presenter?.presentFilteredItems(items)
        }
    }
    
    func loadData(){
        localStore.loadConversations(noRecords: noRecords, noPages: 0, desc: true, completionHandler: { [weak self] res, err in
            if let convs = res {
                self?.presenter?.presentAllItems(convs)
            } else {
                print(err?.localizedDescription ?? "")
            }
        })
    }
    
    func loadMoreData(tableOffset : CGFloat){
        let pages = Int(tableOffset / offset)
        //print(pages)
        
        guard pages - currPage >= 1 else {
            return
        }
        
        currPage = pages
        
        localStore.loadConversations(noRecords: noRecords, noPages: pages, desc: true) { [weak self] res, err in
            if res == nil || res!.isEmpty {
                print("empty fetch!")
                return}
            
            self?.presenter?.presentAllItems(res!)
            
        }
    }
    
    
    func deleteConversation(item: ConversationDomain, indexPath: IndexPath){
        
        localStore.onDeleteConversation(id: item.id)
        
        self.presenter?.presentDeleteItem(item, at: indexPath)
    }


}
