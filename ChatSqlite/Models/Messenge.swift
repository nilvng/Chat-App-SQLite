
//  Message.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation

enum MessengeType : String, Codable {
    case text, image, gif
}

protocol Message{
    var conversationId : String {get set}
    var content : String {get}
    var type : MessengeType {get}
    var timestamp : Date {get}
    var sender : String {get}
}

struct MessengeSQLite : Message, Codable {
    var conversationId : String 

    var content: String
    
    var type: MessengeType
    
    var timestamp: Date
    
    var sender: String
    
    
}


