//
//  ChannelHandlers.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO


private final class ChatHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    private func printByte(_ byte: UInt8) {
        #if os(Android)
        print(Character(UnicodeScalar(byte)),  terminator:"")
        #else
        fputc(Int32(byte), stdout) // print only character
        #endif
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        guard let eventType : UInt8 = buffer.readInteger() else {
            print("Incorrect format")
            return
        }
        print("Event: \(eventType)")
        print("Message: \(String(describing: buffer.readString(length: buffer.readableBytes - 1)))")
    }
    
    func channelActive(context: ChannelHandlerContext) {
        print("activated")
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        print("Deactivated. Retry plz...")
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }
}

private final class SendMessageHandler: ChannelOutboundHandler {
    typealias OutboundIn = String
    typealias OutboundOut = ByteBuffer

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buf = context.channel.allocator.buffer(capacity: 20)
        buf.writeInteger(1 as Int8)
        let st = unwrapOutboundIn(data)
        buf.writeString(st)
        context.writeAndFlush(wrapOutboundOut(buf), promise: promise)
        
        }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }
}
