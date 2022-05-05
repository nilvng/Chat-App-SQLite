//
//  Conversation.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation
import UIKit
import SQLite

protocol Conversation {

    var theme: ThemeOptions? {get set}
    var thumbnail: String? {get set}
    var title: String! {get set}
    var id: String! {get set}
    var members: String! {get set}
    var lastMsg : String! {get set}
    var timestamp : Date! {get set}
    var status : MessageStatus! {get set}
    var mid : String! {get set}

    func toUIModel() -> ConversationDomain
    mutating func fromUIModel(c : ConversationDomain)
}

struct ConversationSQLite : SQLiteModel, Conversation {
    
    
    func toUIModel() -> ConversationDomain {
        var c =  ConversationDomain(theme: nil, thumbnail: thumbnail, title: title,
                                    id: id, members: members,
                                    lastMsg: lastMsg, timestamp: timestamp, mid: mid)
        c.theme = self.theme?.getTheme()
        c.status = self.status
        return c
    }
    
    mutating func fromUIModel(c: ConversationDomain){
        if let t = c.theme {
            theme =  ThemeOptions.fromTheme(t)
        }
        thumbnail = c.thumbnail
        title = c.title
        id = c.id
        members = c.members
        lastMsg = c.lastMsg
        timestamp = c.timestamp
        status = c.status
        mid = c.mid
    }
    
    init(){}
    
    var thumbnail: String?
    
    var title: String!
    
    var id: String!
    
    var members: String!
    
    var theme: ThemeOptions?

    var lastMsg : String!
    
    var timestamp: Date!
    
    var status : MessageStatus! = .seen
    var mid: String!

    
}
