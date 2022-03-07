//
//  Reconnector.swift
//  ChatSqlite
//
//  Created by LAP11353 on 04/03/2022.
//

import Foundation
import NIO

final class Reconnector {
    private var task: RepeatedTask? = nil
    private let bootstrap: ClientBootstrap
    let host = SocketService.shared.host
    let port = SocketService.shared.port
    
    init(bootstrap: ClientBootstrap) {
        self.bootstrap = bootstrap
    }

    func reconnect(on loop: EventLoop) {
        self.task = loop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(10)) { task in
            print("reconnecting")
            try self._tryReconnect()
        }
    }

    private func _tryReconnect() throws {
        self.bootstrap.connect(host:  host, port: port).whenSuccess { _ in
            print("reconnect successful!")
            self.task?.cancel()
            self.task = nil
        }
    }
}
