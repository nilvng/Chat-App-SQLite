//
//  ConversationDataSource.swift
//  ChatSqlite
//
//  Created by LAP11353 on 31/12/2021.
//

import Foundation
import UIKit

class ConversationDataSource : NSObject {
    var items : [ConversationDomain] = []
    var filteredItems : [ConversationDomain] = []
    var isFiltering: Bool = false
    
    static var CELL_ID = "messCell"
    
    func loadItems(_ items: [ConversationDomain]){
        self.items = items
        filteredItems = items
    }
    func updateItem(){
        
    }
    
    func getItem(ip i : IndexPath) -> ConversationDomain{
        return items[i.row]
        
    }
    
    func updateLastMessenge(_ msg : MessageDomain, at i : IndexPath){
        var c = items[i.row]
        c.lastMsg = msg.content
        c.timestamp = msg.timestamp
        items[i.row] = c
    }
    func getIndexOfItem(_ item: ConversationDomain) -> Int? {
        let i = filteredItems.firstIndex(where: { $0.id == item.id})
        return i
    }
    
    func getItem(at index: IndexPath) -> ConversationDomain{
        return filteredItems[index.row]
    }
    
    func filterItemBy(key: String){
        guard key != "" else {
            self.clearSearch()
            return
        }
        isFiltering = true
        self.filteredItems = self.items.filter { item in
            return item.title.lowercased().contains(key.lowercased())
        }
        
        }
    
    func clearSearch(){
        print("clear search.")
        isFiltering = false
        filteredItems = items
    }
}

extension ConversationDataSource : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        
        cell.configure(model: filteredItems[indexPath.row])
        return cell
        
    }
    
}

