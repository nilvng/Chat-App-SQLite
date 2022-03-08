//
//  RawSocketClient.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO
import Alamofire
import SQLite
import Combine

public final class RawSocketClient {
    public let group: MultiThreadedEventLoopGroup
    public let config: Config
    private var channel: Channel?
    private var bootstrap : ClientBootstrap!

    var delayCount : Int = 1
    var backoffBase : Int = 2
//    var task : Scheduled<EventLoopFuture<Bool>? = nil
    
    public init(
        group: MultiThreadedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount), config: Config = Config()
        ) {
        self.group = group
        self.config = config
        self.channel = nil
        self.state = .initializing
    }

    deinit {
        assert(.disconnected == self.state)
//        try channel?.eventLoop.shutdownGracefully()
    }

    public func connect(host: String, port: Int){
        assert(.initializing == self.state)

        self.bootstrap = ClientBootstrap(group: self.group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                return channel.pipeline.addTimeoutHandlers(self.config.timeout)
//                    .flatMap {
//                        channel.pipeline.addFramingHandlers(framing: self.config.framing)}
                    .flatMap {
                        channel.pipeline.addHandlers([
                            ModelCodecHandlers<MessageSocketModel, MessageSocketModel>(),
                            DelegateHandlers(delegate: SocketService.shared, channelDelegate: self),
                        ])
                    }
            }
        
        self.state = .connecting("\(host):\(port)")
        
        self._connect(host: host, port: port)
    }
    
    private func _connect(host: String, port: Int) {
        bootstrap.connect(host: host, port: port).whenComplete { res in
            let _ = res.map { channel in
                self.channel = channel
                self.state = .connected
            }
            if self.state != .connected {
                print("Connection failed")
                self.reconnect(host: host, port: port)
            }
        }
        
    }
    
    public func reconnect(host: String, port: Int) {
        guard delayCount < 5 else {
            return
        }
        print("Reconnecting...\(delayCount)")
        
        let delay = delayCount * backoffBase
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(delay), execute: {
            self.state = .reconnecting
            self._connect(host: host, port: port)
        })
        delayCount += 1
    }
    
    public func onHold(){
        print("\(self) on hold")
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
        if .connected != self.state {
            print("Server disconnected. Cant send...")
            return
            //return self.group.next().makeFailedFuture(ClientError.notReady)
        }
        guard let channel = self.channel else {
            print("Server not exist. Cant send...")
            return
//            return self.group.next().makeFailedFuture(ClientError.notReady)
        }
        channel.writeAndFlush(model, promise: nil)
        
    }

    @Published var _state = State.initializing
    private let lock = NSLock()
    
     var state: State {
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

    enum State: Equatable {
        case initializing
        case connecting(String)
        case connected
        case disconnecting
        case disconnected
        case reconnecting
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
extension RawSocketClient : ChannelHandlerDelegate {
    func channelInactive() {
        self.state = .disconnected
    }
}
internal enum ClientError: Error {
    case notReady
    case cantBind
    case timeout
    case connectionResetByPeer
}
