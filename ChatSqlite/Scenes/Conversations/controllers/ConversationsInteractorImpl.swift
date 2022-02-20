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
    func presentMoreItems(_ items : [ConversationDomain])
    func presentDeleteItem(_ item: ConversationDomain, at: IndexPath)
    func presentFilteredItems(_ items: [ConversationDomain]?)
    func presentNewItem(_ item: ConversationDomain)
    func presentUpsertedItems(item: ConversationDomain)
}

class ConversationsInteractorImpl : ConversationListInteractor{
 
    var localStore : ConversationServiceDecorator
    
    var noRecords : Int = 20
    var currPage = 0
    var offset : CGFloat = 300
    
    init(service : ConversationServiceDecorator){
        self.localStore = service
    }
    
    func filterBy(key: String) {
        localStore.filterConversation(by: key)
    }
    
    func loadData(){
        localStore.loadConversations(noRecords: noRecords, noPages: 0, desc: true)
    }
    
    func loadMoreData(tableOffset : CGFloat){
        let pages = Int(tableOffset / offset)
        //print(pages)
        
        guard pages - currPage >= 1 else {
            return
        }
        
        currPage = pages
        
        localStore.loadConversations(noRecords: noRecords, noPages: pages, desc: true)
    }
    
    
    func deleteConversation(item: ConversationDomain, indexPath: IndexPath){
        
        localStore.deleteConversation(id: item.id)
        
    }


}
