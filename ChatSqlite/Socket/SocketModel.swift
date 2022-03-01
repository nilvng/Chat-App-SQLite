//
//  SocketModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO

enum SocketEvent : Int{
    case messageSent
    case messageReceived
    case messageStatusUpdated
    
    
}

protocol SocketModel {
    func getEvent() -> Int8
    func getBody() -> String
}

struct MessageSocketModel : SocketModel {
    var event: SocketEvent
    var message : MessageDomain
    
    func getEvent() -> Int8 {
        return Int8(event.rawValue)
    }
    
    func getBody() -> String {
        return message.encodeSocketFormat()
    }
    
    init(event: SocketEvent, message: MessageDomain){
        self.event = event
        self.message =  message
        
    }
//
//    init(event: SocketEvent, packet: ByteBuffer){
//        self.event = event
//        self.message = MessageDomain()
//    }
    
}
