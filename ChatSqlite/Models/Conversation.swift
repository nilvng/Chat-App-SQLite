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

    var theme: String? {get}
    var thumbnail: String? {get}
    var title: String {get}
    var id: String {get}
    var members: String {get}
    var lastMsg : String {get set}
    var timestamp : Date {get set}

}

struct ConversationSQLite : SQLiteModel, Conversation {
    
    var theme: String?
    
    var thumbnail: String?
    
    var title: String
    
    var id: String
    
    var members: String

    var lastMsg : String
    
    var timestamp: Date
    
}
