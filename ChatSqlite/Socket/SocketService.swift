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
    
    var reachabilityService : ReachabilityService
    
    var socketClient : RawSocketClient
    weak var delegate : SocketDelegate? = ChatServiceManager.shared
    
    let host = "0.tcp.ngrok.io"
    let port = 13649
    
    private var subscription: AnyCancellable?
    
    init(){
        reachabilityService = ReachabilityService()
        socketClient = RawSocketClient()
        subscription = socketClient.$_state
            .receive(on: RunLoop.main, options: nil)
            .sink { val in
                self.oserveSocketState(state: val)
            }
        reachabilityService.startNetworkObserver { state in
            self.observeNetworkState(state: state)
        }
    }
    
    func observeNetworkState(state: ReachabilityService.State){
        switch state {
        case .wifiConnected:
            print("Wifi connected")
            socketClient.connect(host: host, port: port)
        case .notReachable:
            let _ = socketClient.disconnect() // disconnect former socket if exists
            
            // queue unsent requests
//            socketClient.onHold()
            
            // still try to reconnect
            socketClient.reconnect(host: host, port: port)
        case .cellularConnected:
            socketClient.connect(host: host, port: port)

        }
    }
    
    func oserveSocketState(state: RawSocketClient.State){
        switch state {
        case .connected: break
            //print("\(self) Great!")
        case .disconnected:
            //print("\(self) Bleh")
            let _ = socketClient.disconnect()
            socketClient.reconnect(host: host, port: port)
        case .reconnecting: break
            //print("\(self) Wait a minute")
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
