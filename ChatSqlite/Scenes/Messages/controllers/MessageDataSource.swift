//
//  MessageDataSource.swift
//  ChatSqlite
//
//  Created by LAP11353 on 31/12/2021.
//

import Foundation
import UIKit
import Alamofire

class MessageDataSource : NSObject {
    var items : [MessageDomain] = []
    var msgViewController : MessagesController?
    static var CELL_ID = "messCell"
    
    func setItems(_ items: [MessageDomain]){
        self.items = items
    }
    
    func appendItems(_ items: [MessageDomain]){
                
        self.items += items
    }
    
    
    func appendNewItem(_ item: MessageDomain){
        self.items.insert(item, at: 0)
    }
    
    func isEmpty() -> Bool{
        return items.isEmpty
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
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let reverseIndex = indexPath.row
        let message =  items[reverseIndex]
        message.dropSubscriber()
        
        var isLastContinuous = reverseIndex == 0
        
        if reverseIndex - 1 >= 0 {
            let laterMessage = items[reverseIndex - 1]
            isLastContinuous = laterMessage.sender != message.sender
        }
        
        //if (isLastContinuous){ print("last continuous \(message.content) - \(reverseIndex)")}
        
        cell.configure(with: message, lastContinuousMess: isLastContinuous)
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
    }
    
    func isDownloadable(model: MessageDomain) -> Bool{
        return model.sender != "1" && model.type == .file
    }
    
}
