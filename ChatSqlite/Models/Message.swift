
//  Message.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation

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

struct MessageSQLite : Message, Codable {
    var cid : String

    var content: String
    
    var type: MessageType
    
    var timestamp: Date
    
    var sender: String
    
    
}


