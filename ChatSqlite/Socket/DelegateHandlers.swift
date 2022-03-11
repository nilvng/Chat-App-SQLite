//
//  DelegateHandlers.swift
//  ChatSqlite
//
//  Created by LAP11353 on 03/03/2022.
//

import Foundation
import NIO
protocol ChannelHandlerDelegate : AnyObject {
    func channelInactive()
}
final class DelegateHandlers :ChannelInboundHandler {
    typealias InboundIn = SocketModel
    
    weak var delegate : SocketParserDelegate?
    weak var channelDelegate : ChannelHandlerDelegate?
    
    init(delegate: SocketParserDelegate? = nil, channelDelegate: ChannelHandlerDelegate? = nil){
        self.delegate = delegate
        self.channelDelegate = channelDelegate
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        channelDelegate?.channelInactive()
        print("Channel: inactive")
        
    }
    
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let unwrapData = unwrapInboundIn(data)
        if unwrapData.getEvent() == .messageSent, let model = unwrapData as? MessageSocketModel{
            
            delegate?.onMessageReceived(msg: model.message)
        }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
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
