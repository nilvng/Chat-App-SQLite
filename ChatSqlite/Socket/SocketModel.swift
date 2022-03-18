//
//  SocketModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO

// pattern
/*
    c: conversation ID
    u: user ID
    m: message ID
    S: String (content)
    s: status enum
 */

enum ByteType : Int{
    case enumType = 1
    case idType = 36
    case userIDType = 9
}

enum ParsePattern : Character{
    case c = "c", u = "u", m = "m"
    case s = "s"
    case S = "S"
    
    static func find(char: Character) -> ParsePattern?{
        if char == ParsePattern.c.rawValue {
            return .c
        }
        if char == ParsePattern.u.rawValue {
            return .u
        }
        if char == ParsePattern.m.rawValue {
            return .m
        }
        if char == ParsePattern.S.rawValue {
            return .S
        }
        if char == ParsePattern.s.rawValue {
            return .s
        }
        return nil
    }
 
    func getSize() -> Int {
        switch self {
        case .c:
            return ByteType.userIDType.rawValue
        case  .m:
            return ByteType.idType.rawValue
        case .u:
            return ByteType.userIDType.rawValue
        case .s:
            return ByteType.enumType.rawValue
        case .S:
            // unlimit
            return 30
        }
    }
    
//    func getType() -> ByteType {
//        switch self {
//        case .c, .u, .m, .S:
//            return .stringType
//        case .s:
//            return .enumType
//        }
//    }
    
}

enum SocketEvent : Int{
    case messageSent
    case messageReceived
    case messageStatusUpdated
    
    func getPattern() -> String {
        switch self{
        case .messageSent:
            return "cumS"
        case .messageReceived:
            return "cumS"
        case .messageStatusUpdated:
            return "csm"
        }
    }
    
}

protocol SocketModel {
    func getEvent() -> SocketEvent
    func encodeBody(bytes: ByteBuffer) -> ByteBuffer
    func encode(bytes: ByteBuffer) -> ByteBuffer
    static func decode(bytes: ByteBuffer) -> SocketModel?
}

struct MessageSocketModel : SocketModel {
    
    func encodeBody(bytes: ByteBuffer) -> ByteBuffer {
        let pattern = SocketEvent.messageSent.getPattern()
        var mutableBytes = bytes
        for c in pattern {
            guard let code = ParsePattern.find(char: c) else {
                continue
            }
            switch code {
            case .c:
                mutableBytes.writeString(message.cid)
            case .u:
                mutableBytes.writeString(message.sender)

            case .m:
                mutableBytes.writeString(message.mid)

            case .s:
                continue
            case .S:
                mutableBytes.writeString(message.content)

            }
            
        }
        return mutableBytes
    }
    
    var message : MessageDomain
    
    static func decode(bytes: ByteBuffer) -> SocketModel?{
        var mutableBytes = bytes
        let pattern = SocketEvent.messageSent.getPattern()
        let model = MessageDomain(cid: "", content: "", type: .text, status: .received)
        for c in pattern {
            guard let code = ParsePattern.find(char: c) else {
                continue
            }
            let size = code.getSize()
            switch code {
            case .c:
                guard let cid = mutableBytes.readString(length: size) else {
                    return nil
                }
                model.cid = cid
            case .u:
                guard let sender = mutableBytes.readString(length: size) else {
                    return nil
                }
                model.sender = sender
            case .m:
                guard let mid = mutableBytes.readString(length: size) else {
                    return nil
                }
                model.mid = mid

            case .s:
                continue
            case .S:
                guard let content = mutableBytes.readString(length: mutableBytes.readableBytes) else {
                    return nil
                }
                model.content = content

            }
            
        }
        return MessageSocketModel(message: model)
    }
    
    func encode(bytes: ByteBuffer) -> ByteBuffer {
        var mutable = bytes
        let eventInteger = getEvent().rawValue
        mutable.writeInteger(Int8(eventInteger))
        mutable = encodeBody(bytes: mutable)
        return mutable
    }
    
    func getEvent() -> SocketEvent {
        return .messageSent
    }
    
    func getBody() -> String {
        return message.encodeSocketFormat()
    }
    
    init(message: MessageDomain){
        self.message =  message
    }
    
}
