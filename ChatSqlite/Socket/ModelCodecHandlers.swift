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

final class ModelCodecHandlers<In, Out>: ChannelInboundHandler, ChannelOutboundHandler where In: SocketModel, Out: SocketModel {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = SocketModel
    public typealias OutboundIn = Out
    public typealias OutboundOut = ByteBuffer


    
    func channelActive(context: ChannelHandlerContext) {
        let uid = UserSettings.shared.getUserID()
        let buff = context.channel.allocator.buffer(string: uid)
        context.writeAndFlush(wrapOutboundOut(buff), promise: nil)
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        guard let eventType : UInt8 = buffer.readInteger() else {
            print("Incorrect format")
            return
        }
        print("Event: \(eventType)")
        
        if eventType == 0 {
            guard let model = MessageSocketModel.decode(bytes: buffer) else {
                print("Failed to decode Received Message")
                return
            }
            context.fireChannelRead(wrapInboundOut(model))


        } else {
            print("HANDLER: unknown event")
        }

    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buf = context.channel.allocator.buffer(capacity: 7)
        let model = unwrapOutboundIn(data)
        buf = model.encode(bytes: buf)
        context.writeAndFlush(wrapOutboundOut(buf), promise: promise)
    }
}
