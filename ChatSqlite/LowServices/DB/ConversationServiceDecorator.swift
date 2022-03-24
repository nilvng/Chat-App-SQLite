//
//  ConversationServiceDecorator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 18/02/2022.
//

import Foundation
import Alamofire
class ConversationServiceDecorator{

    static let shared = ConversationServiceDecorator()
    
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
    
    func updateConversation(_ c: ConversationDomain){
        dbStore.updateItem(c, completionHandler: { [weak self] err in
            guard let err = err else {
                return
            }
            print("\(String(describing: self)): \(err.localizedDescription)")
        })
        self.observer?.presentUpdatedItem(c)
    }
    
    func upsertConversation(_ c: ConversationDomain){
        observer?.presentUpsertedItem(item: c)
        dbStore.upsertItem(c, completionHandler: { err in
            guard let err = err else {
                return
            }
            print(err.localizedDescription)
        })
    }
    func fetchAllItems(noRecords: Int, noPages: Int, desc: Bool){
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
