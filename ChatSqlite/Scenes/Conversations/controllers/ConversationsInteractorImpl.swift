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
    func presentUpsertedItem(item: ConversationDomain)
    func presentUpdatedItem(_ item: ConversationDomain)
}

class ConversationsInteractorImpl : ConversationListInteractor{
    func selectConversation(_ c: ConversationDomain) {
        // notify member of this conversation that we already seen all message
        var conv = c
        if conv.status == .received {
            conv.status = .seen
            localStore.upsertConversation(conv)
            SocketService.shared.sendStateSeen(of: conv)
        }
    }
    
 
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
        localStore.fetchAllItems(noRecords: noRecords, noPages: 0, desc: true)
    }
    
    func loadMoreData(tableOffset : CGFloat){
        let pages = Int(tableOffset / offset)
        //print(pages)
        
        guard pages - currPage >= 1 else {
            return
        }
        
        currPage = pages
        
        localStore.fetchAllItems(noRecords: noRecords, noPages: currPage, desc: true)
    }
    
    
    func deleteConversation(item: ConversationDomain, indexPath: IndexPath){
        
        localStore.deleteConversation(id: item.id)
        
    }


}
