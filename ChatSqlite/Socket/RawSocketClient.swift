//
//  RawSocketClient.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO

public final class RawSocketClient {
    public let group: MultiThreadedEventLoopGroup
    public let config: Config
    private var channel: Channel?

    public init(
        group: MultiThreadedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
                config: Config = Config()) {
        self.group = group
        self.config = config
        self.channel = nil
        self.state = .initializing
    }

    deinit {
        assert(.disconnected == self.state)
//        try channel?.eventLoop.shutdownGracefully()
    }

    public func connect(host: String, port: Int) -> EventLoopFuture<RawSocketClient> {
        assert(.initializing == self.state)

        let bootstrap = ClientBootstrap(group: self.group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                return channel.pipeline.addTimeoutHandlers(self.config.timeout)
//                    .flatMap {
//                        channel.pipeline.addFramingHandlers(framing: self.config.framing)}
                    .flatMap {
                        channel.pipeline.addHandlers([
                            ModelCodecHandlers<MessageSocketModel, MessageSocketModel>(),
                            DelegateHandlers(delegate: SocketService.shared),
                        ])
                    }
            }

        self.state = .connecting("\(host):\(port)")
        return bootstrap.connect(host: host, port: port).flatMap { channel in
            self.channel = channel
            self.state = .connected
            return channel.eventLoop.makeSucceededFuture(self)
        }
    }

    public func disconnect() -> EventLoopFuture<Void> {
        if .connected != self.state {
            return self.group.next().makeFailedFuture(ClientError.notReady)
        }
        guard let channel = self.channel else {
            return self.group.next().makeFailedFuture(ClientError.notReady)
        }
        self.state = .disconnecting
        channel.closeFuture.whenComplete { _ in
            self.state = .disconnected
        }
        channel.close(promise: nil)
        return channel.closeFuture
    }

    func send(model: MessageSocketModel){
//        if .connected != self.state {
//            print("Server disconnected. Cant send...")
//            return
//            //return self.group.next().makeFailedFuture(ClientError.notReady)
//        }
        guard let channel = self.channel else {
            print("Server not exist. Cant send...")
            return
//            return self.group.next().makeFailedFuture(ClientError.notReady)
        }
        channel.writeAndFlush(model, promise: nil)
        
    }

    private var _state = State.initializing
    private let lock = NSLock()
    private var state: State {
        get {
            return self.lock.withLock {
                _state
            }
        }
        set {
            self.lock.withLock {
                _state = newValue
                print("\(self) \(_state)")
            }
        }
    }

    private enum State: Equatable {
        case initializing
        case connecting(String)
        case connected
        case disconnecting
        case disconnected
    }


    public struct Config {
        public let timeout: TimeAmount
        public let framing: Framing

        public init(timeout: TimeAmount = TimeAmount.seconds(5), framing: Framing = .default) {
            self.timeout = timeout
            self.framing = framing
        }
    }
}

private class Handler: ChannelInboundHandler, ChannelOutboundHandler {
    typealias InboundIn = ByteBuffer
    
    public typealias OutboundIn = ByteBuffer

    // outbound
    public func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let requestWrapper = self.unwrapOutboundIn(data)
        //context.write(wrapOutboundOut(requestWrapper.request), promise: promise)
    }


    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if (event as? IdleStateHandler.IdleStateEvent) == .read {
            //self.errorCaught(context: context, error: ClientError.timeout)
        } else {
            context.fireUserInboundEventTriggered(event)
        }
    }
    public func channelActive(context: ChannelHandlerContext) {
        if let remoteAddress = context.remoteAddress {
            print("server", remoteAddress, "connected")
        }
    }

    public func channelInactive(context: ChannelHandlerContext) {
        if let remoteAddress = context.remoteAddress {
            print("server ", remoteAddress, "disconnected")
        }
        //if !self.queue.isEmpty { // currently running
            //self.errorCaught(context: context, error: ClientError.connectionResetByPeer)
        //}
    }
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        if let remoteAddress = context.remoteAddress {
            print("server", remoteAddress, "error", error)
        }
//        if self.queue.isEmpty {
//            return context.fireErrorCaught(error) // already complete
//        }
//        let item = queue.removeFirst()
//        let requestId = item.0
//        let promise = item.1
        switch error {
        case CodecError.requestTooLarge, CodecError.badFraming, CodecError.badJSON:
            break
            //promise.succeed(JSONResponse(id: requestId, errorCode: .parseError, error: error))
        default:
//            promise.fail(error)
            // close the connection
            context.close(promise: nil)
        }
    }
}
internal enum ClientError: Error {
    case notReady
    case cantBind
    case timeout
    case connectionResetByPeer
}
