
//  Message.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation
import SQLite

enum MessageType : String, Codable {
    case text, image, gif
}

protocol Message{
    var cid : String {get set}
    var content : String {get}
    var type : MessageType {get}
    var timestamp : Date {get}
    var sender : String {get}
}

protocol SQLiteModel : Codable{
    
}

struct MessageSQLite : SQLiteModel, Message {
    var cid : String

    var content: String
    
    var type: MessageType
    
    var timestamp: Date
    
    var sender: String
    
    enum MsgExpression {
        case cid
        case content
        
//        func getExpression() -> Expression<Any>{
//            switch self{
//            case .cid:
//                return Expression<String>("cid")
//
//            case .content:
//                return Expression<String>("content")
//            }
//        }
    }
}


