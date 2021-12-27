
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
    var cid : String! {get set}
    var content : String! {get}
    var type : MessageType! {get}
    var timestamp : Date! {get}
    var sender : String! {get}
    
    func toUIModel() -> MessagesModel
    
    mutating func fromUIModel(c: MessagesModel)
}

protocol SQLiteModel : Codable{

}

struct MessageSQLite : SQLiteModel, Message {
    func toUIModel() -> MessagesModel {
        return MessagesModel(cid: cid, content: content, type: type, timestamp: timestamp, sender: sender)
    }
    
    mutating func fromUIModel(c: MessagesModel) {
        cid = c.cid
        content = c.content
        self.type = c.type
        self.timestamp = c.timestamp
        self.sender = c.sender
    }
    
    var cid : String!

    var content: String!
    
    var type: MessageType!
    
    var timestamp: Date!
    
    var sender: String!
    
    init(){
    }
    
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


