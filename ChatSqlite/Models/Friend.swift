//
//  Friend.swift
//  ChatCoreData
//
//  Created by LAP11353 on 14/12/2021.
//

import Foundation

protocol Friend {

    var avatar: String? {get}
    var id: String {get}
    var phoneNumber: String {get}
    var name: String {get}

    
}

struct FriendSqlite : SQLiteModel, Friend {
    
    var avatar: String?
    
    var id: String
    
    var phoneNumber: String
    
    var name: String

}
