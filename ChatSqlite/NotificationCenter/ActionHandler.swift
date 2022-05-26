//
//  ActionHandler.swift
//  ChatSqlite
//
//  Created by LAP11353 on 26/05/2022.
//

import Foundation
import NotificationCenter

protocol ActionHandler{
    func execute(response : UNNotificationResponse)
}

struct MessageReplyHandler : ActionHandler {
    static let actionID : String = "reply"
    let categoryID : String = "Message"
    let chatManager : ChatServiceManager = ChatServiceManager.shared
    
    func execute(response : UNNotificationResponse) {
        guard let textResponse = response as? UNTextInputNotificationResponse else {
            fatalError()
        }
        let text = textResponse.userText
        guard let cid = textResponse.notification.request.content.userInfo["cid"] as? String else{
            return
        }
        let m = MessageDomain(cid: cid, content: text, type: .text, status: .sent, downloaded: false)
        chatManager.sendMessage(msg: m, completion: { working in
            print("\(self) successfully send msg")
        })
    }
}


struct MessageDefaultHandler : ActionHandler {
    static let actionID : String = "msgDefault"
    let categoryID : String = "Message"
    let chatManager : ChatServiceManager = ChatServiceManager.shared
    let coordinator : ChatCoordinator? = ChatCoordinator.shared
    
    func execute(response : UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let convID = userInfo["cid"] as! String
        chatManager.getChatService(cid: convID, completion: { service in
            guard let service = service else {
                return
            }
            let conv = service.conversatioNWorker.model!
            coordinator?.navigate(to: .chatView(model: conv))
        })
    }
}
