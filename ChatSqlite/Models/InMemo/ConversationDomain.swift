//
//  ConversationsModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation
import Combine

struct ConversationDomain{
    internal init(theme: Theme? = nil, thumbnail: String? = nil, title: String, id: String, members: String, lastMsg: String, timestamp: Date, status: MessageStatus = .seen, mid: String) {
        self.theme = theme
        self.thumbnail = thumbnail
        self.title = title
        self.id = id
        self.members = members
        self.lastMsg = lastMsg
        self.timestamp = timestamp
        self.status = status
        self.mid = mid
    }
    
    static func fromFriend(friend: FriendDomain) -> ConversationDomain {
        return ConversationDomain(theme: .basic, thumbnail: nil,
                                  title: friend.name, id: friend.id,
                                  members: friend.id,
                                  lastMsg: "", timestamp: Date(), mid: "")
    }
    
    var theme: Theme?
    
    var thumbnail: String?
    
    var title: String
    
    var id: String
    
    var members: String
    
    var lastMsg: String
    
    var timestamp: Date
    
    var status : MessageStatus = .seen
    
    var mid : String
    
}

extension ConversationDomain : Equatable {
    static func == (lhs: ConversationDomain, rhs: ConversationDomain) -> Bool {
        return lhs.id == rhs.id
    }
}
