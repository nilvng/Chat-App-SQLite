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
import UIKit

public final class RawSocketClient {
    public let group: MultiThreadedEventLoopGroup
    public let config: Config
    private var channel: Channel?
    private var bootstrap : ClientBootstrap!

    var reconnectCounter : Int = 0
//    var host : String
//    var port Int
    
    public init(
        group: MultiThreadedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
        config: Config = Config()
        ) {
        self.group = group
        self.config = config
        self.channel = nil
        self.state = .initializing
        self.bootstrap = ClientBootstrap(group: self.group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                return
//                channel.pipeline.addTimeoutHandlers(self.config.requestTimeout)
//                    .flatMap {
//                        channel.pipeline.addFramingHandlers(framing: self.config.framing)}
//                    .flatMap {
                        channel.pipeline.addHandlers([
                            ModelCodecHandlers(),
                            DelegateHandlers(delegate: SocketService.shared, channelDelegate: self),
                            ModelCodecOutboundHandler()
                        ])
//                    }
            }
        
    }

    deinit {
        assert(.disconnected == self.state)
        
    }

    public func connect(host: String, port: Int){
        let st_connect = "\(host) : \(port)"
        
        // already connect to the same host and port
        assert(self.state != .connecting(st_connect) && self.state != .connected)
        
        self.state = .connecting(st_connect)
        
        bootstrap.connect(host: host, port: port).whenComplete { res in

            guard self.state == .connecting(st_connect) else {
                print("\(self) Warning: completed connection but already connected? Leaving..")
                return
            }
   
            let _ = res.map( { channel in
                self.channel = channel
                self.state = .connected
            })
            
            /// the above closure didn't run -> res = failure 
            if self.state != .connected { //
//                print("\(self) Error: Connection failed")
                self.state = .disconnected
            }
        }
        
    }
    
    public func reconnect(host: String, port: Int) {
        
        guard state == .disconnected else {
            return
        }
        
        if reconnectCounter >= config.reconnectAttempt {
            reconnectCounter = 0
        }
        reconnectCounter += 1
//        print("Reconnecting...\(reconnectCounter)")
                
        self.state = .reconnecting
        let delay = reconnectCounter * config.connectTimeout
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(delay), execute: {
            self.connect(host: host, port: port)
        })
        
    }
    
    public func onHold(){
        // Change wifi, reconnect to server
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
        
        // design callback for closing channel
        channel.closeFuture.whenComplete { _ in
            
            guard self.state == .disconnecting else {
                print("\(self) Warning: going to disconnect but not in state of disconnecting?")
                return
            }
            
            self.state = .disconnected
        }
        
        channel.close(promise: nil) // actually close channel
        
        return channel.closeFuture
    }

    func send(model: SocketModel){
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
//                print("\(self) \(_state)")
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
        public let requestTimeout: TimeAmount
        public let connectTimeout : Int
        public let reconnectAttempt : Int
        public let framing: Framing
        

        public init(timeout: TimeAmount = TimeAmount.seconds(60),
                    framing: Framing = .default,
                    connectTimeout: Int = 2,
                    reconnectAttempt: Int = 5) {
            self.requestTimeout = timeout
            self.framing = framing
            self.connectTimeout = connectTimeout
            self.reconnectAttempt = reconnectAttempt
        }
    }
    
}
extension RawSocketClient : ChannelHandlerDelegate {
    func channelInactive() {
        // due to down server, wifi disconnected
        let _ = self.disconnect()
    }
}
internal enum ClientError: Error {
    case notReady
    case cantBind
    case timeout
    case connectionResetByPeer
}
