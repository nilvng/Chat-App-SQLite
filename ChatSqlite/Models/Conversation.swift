//
//  Conversation.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation
import UIKit
import SQLite

struct Theme : Codable {
        
    typealias Datatype = String
    
    var bubbleColor : Datatype = "blue-purple"
    var background : Datatype = "default"
    var accentColor : Datatype = "blue"
}

extension Theme {
    static var v0 = Theme()
    static var v1 = Theme(bubbleColor: "green-orange", background: "forrest", accentColor: "greeny")
}

protocol Conversation {

    var theme: String? {get set}
    var thumbnail: String? {get set}
    var title: String! {get set}
    var id: String! {get set}
    var members: String! {get set}
    var lastMsg : String! {get set}
    var timestamp : Date! {get set}
    func toUIModel() -> ConversationDomain
    mutating func fromUIModel(c : ConversationDomain)
}

struct ConversationSQLite : SQLiteModel, Conversation {
    func toUIModel() -> ConversationDomain {
    return ConversationDomain(theme: theme, thumbnail: thumbnail, title: title, id: id, members: members, lastMsg: lastMsg, timestamp: timestamp)
    }
    
    mutating func fromUIModel(c: ConversationDomain){
    theme =  c.theme
    thumbnail = c.thumbnail
    title = c.title
    id = c.id
    members = c.members
    lastMsg = c.lastMsg
    timestamp = c.timestamp
    }
    
    init(){}
    
    
    var theme: String?
    
    var thumbnail: String?
    
    var title: String!
    
    var id: String!
    
    var members: String!

    var lastMsg : String!
    
    var timestamp: Date!
    
}
