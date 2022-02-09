//
//  SceneBusinessLogic.swift
//  ChatSqlite
//
//  Created by LAP11353 on 09/02/2022.
//

import Foundation

protocol MessageListBusinessLogic {

    func sendMessage(msg: MessageDomain)
    func receiveMessage(msg: MessageDomain)
    func downloadMessage(msg: MessageDomain)
    
}

protocol ConversationListBusinessLogic {

    
}
