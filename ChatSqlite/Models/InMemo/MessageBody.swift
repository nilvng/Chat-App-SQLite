//
//  MessageBody.swift
//  ChatSqlite
//
//  Created by LAP11353 on 25/03/2022.
//

import Foundation

protocol MessageBody {
    var text : String! {get}
    
    func encode() -> String
    
    func decode(string: String)
}

extension MessageBody {
    
    func encode() -> String {
        return text
    }
}

struct TextMessageBody : MessageBody{

    
    var text: String!
    func decode(string: String) {
        
    }
}

struct ImageMessageBody : MessageBody {
    var text: String!
    
    func decode(string: String) {
        
    }
}
