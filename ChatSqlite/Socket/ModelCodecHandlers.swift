//
//  ModelCodableCodec.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO


final class ModelCodecHandlers: ChannelInboundHandler, ChannelOutboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = SocketModel
    public typealias OutboundIn = SocketModel
    public typealias OutboundOut = ByteBuffer


    
    func channelActive(context: ChannelHandlerContext) {
        print("Channel: active")
        let uid = UserSettings.shared.getUserID()
        let buff = context.channel.allocator.buffer(string: uid)
        context.writeAndFlush(wrapOutboundOut(buff), promise: nil)
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        guard let eventType : Int8 = buffer.readInteger() else {
            print("Incorrect format")
            return
        }
        print("Event: \(eventType)")
        guard let event = SocketEvent(rawValue: Int(eventType)) else {
            print("Parse non-exist event: \(eventType)")
            return
        }
        switch event{
            
        case .messageSent:
            guard let model = MessageSocketModel.decode(bytes: buffer) else {
                print("Failed to decode Received Message")
                return
            }
            context.fireChannelRead(wrapInboundOut(model))
            
            return
        case .messageStatusUpdated:
            guard let model = MsgStatusSocketModel.decode(bytes: buffer) else {
                print("Failed to decode Msg status.")
                return
            }
            context.fireChannelRead(wrapInboundOut(model))
        default:
            return
            
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buf = context.channel.allocator.buffer(capacity: 7)
        let model = unwrapOutboundIn(data)
        buf = model.encode(bytes: buf)
        context.writeAndFlush(wrapOutboundOut(buf), promise: promise)
    }
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
            print("Channel Error: \(error.localizedDescription)")
            ctx.close(promise: nil)
        }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if (event as? IdleStateHandler.IdleStateEvent) == .read {
            self.errorCaught(context: context, error: ClientError.timeout)
        } else {
            context.fireUserInboundEventTriggered(event)
        }
    }
}
