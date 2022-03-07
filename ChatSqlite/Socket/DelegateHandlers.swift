//
//  DelegateHandlers.swift
//  ChatSqlite
//
//  Created by LAP11353 on 03/03/2022.
//

import Foundation
import NIO

final class DelegateHandlers :ChannelInboundHandler {
    typealias InboundIn = SocketModel
    
    weak var delegate : SocketParserDelegate?
    
    init(delegate: SocketParserDelegate? = nil){
        self.delegate = delegate
    }

    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let unwrapData = unwrapInboundIn(data)
        if unwrapData.getEvent() == .messageSent, let model = unwrapData as? MessageSocketModel{
            
            delegate?.onMessageReceived(msg: model.message)
        }
    }
}
