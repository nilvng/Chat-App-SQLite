//
//  MessageCellInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 14/02/2022.
//

import Foundation

protocol MessageCellPresenter : AnyObject, MessageSubscriber {
    
}

class MessageCellInteractor {
    weak var presenter : MessageCellPresenter?
    lazy var friendSerivce : FriendService = NativeContactStoreAdapter.shared

    func downloadMessage(_ msg: MessageDomain){
        
        msg.download(sub: presenter)
    }
    
    func findFriend(fid: String, callback: @escaping (FriendDomain?, StoreError?) -> Void){
        friendSerivce.fetchItemWithId(fid, completionHandler: callback)

    }
}
