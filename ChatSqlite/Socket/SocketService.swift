//
//  SocketService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 25/02/2022.
//

import Foundation
import NIO
import Combine

class SocketService {
    static var shared = SocketService()
    
    var socketClient : RawSocketClient
    weak var delegate : SocketDelegate?
    
    let host = "127.0.0.1"
    let port = 3000
    
    private var subscription: AnyCancellable?
    
    init(){
        socketClient = RawSocketClient()
        subscription = socketClient.$_state
            .receive(on: RunLoop.main, options: nil)
            .sink { val in
                self.oserveSocketState(state: val)
            }
    }
    
    func oserveSocketState(state: RawSocketClient.State){
        switch state {
        case .connected:
            print("Great! Socket is connected")
        case .disconnected:
            print("Bleh, Socket is disconnected")
        case .reconnecting:
            print("Wait a minute, reconnecting...")
        default:
            return
        }
    }
    
    func connect(){
        let _ = socketClient.connect(host: host, port: port)
        
    }
    
    func sendMessage(_ msg: MessageDomain){
        let socketModel = MessageSocketModel(message: msg)
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
