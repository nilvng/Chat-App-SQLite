//
//  ModelCodecOutboundHandler.swift
//  ChatSqlite
//
//  Created by LAP11353 on 23/03/2022.
//

import Foundation
import NIO
class ModelCodecOutboundHandler : ChannelOutboundHandler {
    typealias OutboundIn = SocketModel
    typealias OutboundOut = ByteBuffer

    
    func channelActive(context: ChannelHandlerContext) {
        print("Channel: active")
        let uid = UserSettings.shared.getUserID()
        let buff = context.channel.allocator.buffer(string: uid)
        context.writeAndFlush(wrapOutboundOut(buff), promise: nil)
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buf = context.channel.allocator.buffer(capacity: 7)
        
        let model = unwrapOutboundIn(data)
        buf = model.encode(bytes: buf)
        context.writeAndFlush(wrapOutboundOut(buf), promise: promise)
    }
}
