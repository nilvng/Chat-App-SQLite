//
//  RawSocket.swift
//  ChatSqlite
//
//  Created by LAP11353 on 27/02/2022.
//

import Foundation
import NIO
import NIOPosix



//let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
//let bootstrap = ClientBootstrap(group: group)
//    .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
//    .channelInitializer { channel in
//        return channel.pipeline.addHandler(ChatHandler()).flatMap {
//                    channel.pipeline.addHandler(SendMessageHandler())
//                }
//    }
//defer {
//    try! group.syncShutdownGracefully()
//}
//print("Hello, World!")
//
//let host = "127.0.0.1"
//let port = 3000
//let path = "http://ee6e-2405-4803-c6b8-8c00-4414-d99d-d8b0-45d2.ngrok.io"
//let channel = try { () -> Channel in
//    try bootstrap.connect(host: host, port: port).wait()
//}()
//
//print("ChatClient connected to ChatServer: \(channel.remoteAddress!), \nHappy chatting\n.")
//while let line = readLine(strippingNewline: false) {
//    let _ = channel.writeAndFlush(line, promise: nil)
//}
//
//// EOF, close connect
//try! channel.close().wait()
//
//print("ChatClient closed")

