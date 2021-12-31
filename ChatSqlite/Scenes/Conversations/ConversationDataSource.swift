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
    static var CELL_ID = "messCell"
    
    func loadItems(_ items: [ConversationDomain]){
        self.items = items
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
}

extension ConversationDataSource : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationDataSource.CELL_ID) as? SubtitleCell else {
            fatalError()
        }
                
        cell.textLabel?.text = items[indexPath.row].title
        cell.detailTextLabel?.text = items[indexPath.row].lastMsg
        return cell
    }
    
}

