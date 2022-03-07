//
//  Utls.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO

extension Notification.Name {
    static let  networkChanged = Notification.Name("NetworkChanged")
}

public enum ResultType<Value, Error> {
    case success(Value)
    case failure(Error)
}

public enum Framing: CaseIterable {
    case `default`
    case jsonpos
    case brute
}

internal extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        self.lock()
        defer {
            self.unlock()
        }
        return body()
    }
}
private let maxPayload = 1_000_000 // 1MB
internal extension ChannelPipeline {
    func addTimeoutHandlers(_ timeout: TimeAmount) -> EventLoopFuture<Void> {
        return self.addHandlers([IdleStateHandler(readTimeout: timeout), HalfCloseOnTimeout()])
    }
}

internal extension ChannelPipeline {
//    func addFramingHandlers(framing: Framing) -> EventLoopFuture<Void> {
//        let eventParser = FramingCodec()
//        return self.addHandlers([ByteToMessageHandler(eventParser),
//                                             MessageToByteHandler(eventParser)])
//    }
}


internal final class HalfCloseOnTimeout: ChannelInboundHandler {
    typealias InboundIn = Any

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if event is IdleStateHandler.IdleStateEvent {
            // this will trigger ByteToMessageDecoder::decodeLast which is required to
            // recognize partial frames
            context.fireUserInboundEventTriggered(ChannelEvent.inputClosed)
        }
        context.fireUserInboundEventTriggered(event)
    }
}
