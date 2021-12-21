//
//  Conversation.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation

protocol Conversation {

    var theme: String? {get}
    var thumbnail: String? {get}
    var title: String {get}
    var id: String {get}
    var members: String {get}
    var lastMsg : String {get set}
    var timestamp : Date {get set}

    static func fromFriend(friend : Friend) -> Conversation
}

struct ConversationSQLite : Codable, Conversation {
    static func fromFriend(friend: Friend) -> Conversation {
        return ConversationSQLite(theme: nil, thumbnail: nil,
                                  title: friend.name, id: UUID().uuidString,
                                  members: friend.id,
                                  lastMsg: "", timestamp: Date())
    }
    
    var theme: String?
    
    var thumbnail: String?
    
    var title: String
    
    var id: String
    
    var members: String

    var lastMsg : String
    
    var timestamp: Date
    
}
