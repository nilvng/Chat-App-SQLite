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
    
    func downloadMessage(_ msg: MessageDomain){
        
        msg.download(sub: presenter)
    }
}
