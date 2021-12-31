//
//  MessageDataSource.swift
//  ChatSqlite
//
//  Created by LAP11353 on 31/12/2021.
//

import Foundation
import UIKit

class MessageDataSource : NSObject {
    var items : [MessageDomain] = []
    static var CELL_ID = "messCell"
    
    func appendItems(_ items: [MessageDomain]){
        self.items += items
    }
    func updateItem(){
        
    }
    
    func getItem(){
        
    }
}

extension MessageDataSource : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageDataSource.CELL_ID, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].content
        return cell
    }
    
}
