//
//  ModelCodableCodec.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO

protocol SocketParserDelegate : AnyObject{
    func onMessageReceived(msg: MessageDomain)
    func onMessageStatusUpdated(mid: String, status: MessageStatus)
}

final class ModelCodecHandler<In, Out>: ChannelInboundHandler, ChannelOutboundHandler where In: SocketModel, Out: SocketModel {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = In
    public typealias OutboundIn = Out
    public typealias OutboundOut = ByteBuffer

    weak var delegate : SocketParserDelegate?
    
    init(delegate: SocketParserDelegate? = nil){
        self.delegate = delegate
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        guard let eventType : UInt8 = buffer.readInteger() else {
            print("Incorrect format")
            return
        }
        print("Event: \(eventType)")
        
        guard let cID = buffer.readString(length: 36),
              let mid = buffer.readString(length: 36),
              let content = buffer.readString(length: buffer.readableBytes) else {
                  print("Failed parse message (1,36,36,content)")
                  return
              }
        
        let msg = MessageDomain(mid: mid + "r", cid: cID, content: content,
                                type: .text, timestamp: Date(), sender: cID)
        delegate?.onMessageReceived(msg: msg)
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buf = context.channel.allocator.buffer(capacity: 7)
        let model = unwrapOutboundIn(data)

        buf.writeInteger(model.getEvent() as Int8)
        buf.writeString(model.getBody())
        context.writeAndFlush(wrapOutboundOut(buf), promise: promise)
    }
}
