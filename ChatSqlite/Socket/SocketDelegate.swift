//
//  SocketDelegate.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/02/2022.
//

import Foundation

protocol SocketDelegate : AnyObject {
    
    func connected()
    func disconnected()
    func onRetryFailed()
    
    func onMessageSent()
    func onMessageReceived(msg: MessageDomain)
    func onMessageStatusUpdated(cid: String, mid: String, status: MessageStatus)

}
