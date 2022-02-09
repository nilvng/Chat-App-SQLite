//
//  SceneBusinessLogic.swift
//  ChatSqlite
//
//  Created by LAP11353 on 09/02/2022.
//

import Foundation

protocol MessageListBusinessLogic {

    func messageList(sendMessage: MessageDomain)
    func messageList(receiveMessage: MessageDomain)
    func messageList(downloadMessage: MessageDomain)
    
}

protocol ConversationListBusinessLogic {

    
}
