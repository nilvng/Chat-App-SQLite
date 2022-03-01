//
//  ModelCoodec.swift
//  ChatSqlite
//
//  Created by LAP11353 on 01/03/2022.
//

import Foundation
import NIO

internal final class FramingCodec: ByteToMessageDecoder, MessageToByteEncoder {
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        fatalError()
    }
    
    func encode(data: ByteBuffer, out: inout ByteBuffer) throws {
        fatalError()
    }
    
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = ByteBuffer
    public typealias OutboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    
}
