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
    
    let host = "localhost"
    let port = 3000
    var privateQueue  = DispatchQueue(label: "zalo.chatApp.SocketService",
                                      qos: .userInteractive,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    
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
            print("Wifi disconnected??")
            // TODO: disconnect?
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
        case .connected:
            print("\(self) Great!")
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
        privateQueue.async {
            let socketModel = MessageSocketModel(message: msg)
            self.socketClient.send(model: socketModel)
        }

    }
    
    func receiveMessage(_ msg: MessageDomain){
        privateQueue.async {
            self.delegate?.onMessageReceived(msg: msg)
        }
    }
    
    func sendMessageState(msg: MessageDomain, status: MessageStatus, from userID: String){
        privateQueue.async {
            let msgModel = MsgStatusSocketModel(mid: msg.mid, cid: userID, status: status)
            self.socketClient.send(model: msgModel)
        }
       
    }
    
    func sendStateSeen(of conv: ConversationDomain){
        privateQueue.async {
            let myID = UserSettings.shared.getUserID()
            // TODO: Msg status model should have the recipient ID
            self.socketClient.send(model: MsgStatusSocketModel(mid: conv.mid, cid: myID, status: .seen))
        }
  
    }
    
}

extension SocketService : SocketParserDelegate {
    func onMessageReceived(msg: MessageDomain) {
        delegate?.onMessageReceived(msg: msg)
    }
    
    func onMessageStatusUpdated(cid: String, mid: String, status: MessageStatus) {
        delegate?.onMessageStatusUpdated(cid: cid, mid: mid, status: status)
    }
    
}
