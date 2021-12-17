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
    var members: String? {get}

}

struct ConversationSQLite : Conversation, Codable {
    var theme: String?
    
    var thumbnail: String?
    
    var title: String
    
    var id: String
    
    var members: String?
    
    
}
