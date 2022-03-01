//
//  SocketService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 25/02/2022.
//

import Foundation
import NIO

class SocketService {
    static var shared = SocketService()
    
    var socketClient : RawSocketClient
    weak var delegate : SocketDelegate?
    
    let host = "127.0.0.1"
    let port = 3000
    init(){
        socketClient = RawSocketClient()
    }
    
    func connect(){
        let _ = socketClient.connect(host: host, port: port)
    }
    
    func sendMessage(_ msg: MessageDomain){
        let socketModel = MessageSocketModel(event: .messageSent, message: msg)
        socketClient.send(model: socketModel)
    }
    
    func receiveMessage(_ msg: MessageDomain){
        delegate?.onMessageReceived(msg: msg)
    }
    
}

extension SocketService : SocketParserDelegate {
    func onMessageReceived(msg: MessageDomain) {
        delegate?.onMessageReceived(msg: msg)
    }
    
    func onMessageStatusUpdated(mid: String, status: MessageStatus) {
        delegate?.onMessageStatusUpdated(mid: mid, status: status)
    }
    
    
}
