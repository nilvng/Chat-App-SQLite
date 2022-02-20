//
//  ConversationServiceDecorator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation
import Alamofire
class ConversationServiceDecorator {
    weak var observer : ConversationPresenter?
    var dbStore : ConversationService
    
    init(){
        dbStore = ConversationStoreProxy.shared
    }
    
    func addObserver(observer: ConversationPresenter){
        self.observer = observer
    }
    
    func filterConversation(by key: String){
        dbStore.filterBy(key: key, completion: { [weak self] items, err in
            guard let items = items else {
                return
            }
            self?.observer?.presentFilteredItems(items)
        })
    }
    func loadConversations(noRecords: Int, noPages: Int, desc: Bool){
        dbStore.fetchAllItems(noRecords: noRecords, noPages: noPages, desc: desc, completionHandler: { [weak self] items, err in
            guard let items = items else {
                return
            }
            if noPages == 0 {
            self?.observer?.presentAllItems(items)
            } else {
                self?.observer?.presentMoreItems(items)
            }
        })
    }
    
    func deleteConversation(id: String){
        dbStore.deleteItem(id: id, completionHandler: { err in
            
        })
    }
}
