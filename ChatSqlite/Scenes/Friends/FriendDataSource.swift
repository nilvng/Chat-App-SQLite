//
//  FriendDataSource.swift
//  ChatSqlite
//
//  Created by LAP11353 on 31/12/2021.
//

import Foundation
import UIKit

class FriendDataSource : NSObject {
    var items : [FriendDomain] = []
    static var CELL_ID = "friendCell"
    
    func appendItems(_ items: [FriendDomain]){
        self.items += items
    }
    func updateItem(){
        
    }
    
    func getItem(ip i : IndexPath) -> FriendDomain{
        return items[i.row]
        
    }

}

extension FriendDataSource : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendDataSource.CELL_ID, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        return cell
    }
    
}
