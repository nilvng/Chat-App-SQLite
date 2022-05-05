//
//  MsgStatusSocketModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 15/03/2022.
//

import Foundation
import NIO

struct MsgStatusSocketModel : SocketModel {
    internal init(mid: String = "", cid: String, status: MessageStatus) {
        self.mid = mid
        self.cid = cid
        self.status = status
    }
    
    var mid : String
    var cid : String
    var status : MessageStatus
    
    func getEvent() -> SocketEvent {
        return .messageStatusUpdated
    }
    
    func encodeBody(bytes: ByteBuffer) -> ByteBuffer {
        let pattern = SocketEvent.messageStatusUpdated.getPattern()
        var mutableBytes = bytes
        for c in pattern {
            guard let code = ParsePattern.find(char: c) else {
                continue
            }
            switch code {
            case .c:
                mutableBytes.writeString(self.cid)
            case .m:
                mutableBytes.writeString(self.mid ?? "")
            case .s:
                let val = Int8(self.status.rawValue)
                mutableBytes.writeInteger(val)
            default:
                continue
            }
            
        }
        return mutableBytes
    }
    
    func encode(bytes: ByteBuffer) -> ByteBuffer {
        var mutable = bytes
        let eventInteger = getEvent().rawValue
        mutable.writeInteger(Int8(eventInteger))
        mutable = encodeBody(bytes: mutable)
        return mutable
    }
    
    static func decode(bytes: ByteBuffer) -> SocketModel? {
        var mutableBytes = bytes
        let pattern = SocketEvent.messageStatusUpdated.getPattern()
        var cid: String = ""
        var mid: String = ""
        var mstatus : MessageStatus? = nil
        for c in pattern {
            guard let code = ParsePattern.find(char: c) else {
                continue
            }
            let size = code.getSize()
            switch code {
            case .c:
                guard let _cid = mutableBytes.readString(length: size) else {
                    return nil
                }
                cid = _cid
            case .s:
                guard let _status : Int8 = mutableBytes.readInteger() else {
                    return nil
                }
                mstatus = MessageStatus(rawValue: Int(_status))
            case .m:
                print("Msg status bytes left: \(mutableBytes.readableBytes)")
                guard let _mid = mutableBytes.readString(length: mutableBytes.readableBytes) else {
                    if mstatus != nil{
                        return MsgStatusSocketModel(cid: cid, status: mstatus!)
                    } else {
                        return nil
                    }
                }
                mid = _mid
            default:
                continue
            }
        }

        if mstatus != nil{
            return MsgStatusSocketModel(mid: mid, cid: cid, status: mstatus!)
        } else {
            return nil
        }
    }
    
}
