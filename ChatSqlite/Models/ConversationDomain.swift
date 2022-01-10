//
//  ConversationsModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation

struct ConversationDomain {
    static func fromFriend(friend: FriendDomain) -> ConversationDomain {
        return ConversationDomain(theme: .basic, thumbnail: nil,
                                  title: friend.name, id: UUID().uuidString,
                                  members: friend.id,
                                  lastMsg: "", timestamp: Date())
    }
    
    var theme: Theme?
    
    var thumbnail: String?
    
    var title: String
    
    var id: String
    
    var members: String
    
    var lastMsg: String
    
    var timestamp: Date
    
    
}
