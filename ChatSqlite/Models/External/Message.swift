
//  Message.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation
import SQLite

enum MessageType : Int, Codable {
    case text = 0
    case file
    case image
    case gif
    case sticker
}

enum MessageStatus : Int, Codable{
    case sent
    case received
    case arrived
    case seen
}

protocol Message{
    var cid : String! {get set}
    var mid : String! {get}
    var content : String! {get}
    var type : MessageType! {get}
    var timestamp : Date! {get}
    var sender : String! {get}
    var downloaded : Bool! {get}
    var status : MessageStatus! {get}
    
        
    func toUIModel() -> MessageDomain
    
    mutating func fromUIModel(c: MessageDomain)
}

protocol SQLiteModel : Codable{

}

struct MessageSQLite : Message, Codable {
    
    func toUIModel() -> MessageDomain {
        return MessageDomain(mid: mid, cid: cid, content: content, type: type, timestamp: timestamp, sender: sender,downloaded: downloaded, status: status)
    }
    
    mutating func fromUIModel(c: MessageDomain) {
        mid = c.mid
        cid = c.cid
        content = c.content
        self.type = c.type
        self.timestamp = c.timestamp
        self.sender = c.sender
        self.downloaded = c.downloaded
        self.status = c.status
    }
    
    var mid : String! = UUID().uuidString
    
    var cid : String!

    var content: String!
    
    var type: MessageType!
    
    var status: MessageStatus!
    
    var timestamp: Date!
    
    var sender: String!
    
    var downloaded : Bool!
    
    init(){
    }
    
//    enum Keys : String, CodingKey {
//
//        case mid, cid, content, type, timestamp, sender
//    }
//
//    init(from decoder : Decoder) throws{
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        mid = try values.decode(String.self, forKey: .mid)
//        cid = try values.decode(String.self, forKey: .cid)
//        content = try values.decode(String.self, forKey: .content)
//        type = try values.decode(MessageType.self, forKey: .type)
//        timestamp = try values.decode(Date.self, forKey: .timestamp)
//        sender = try values.decode(String.self, forKey: .sender)
//    }
}


