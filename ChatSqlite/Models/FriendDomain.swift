//
//  FriendsModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation

struct FriendDomain {
    var avatar: String?
    
    var id: String
    
    var phoneNumber: String
    
    var name: String
    
    init(){
        id = ""
        phoneNumber = ""
        name = "Default"
        avatar = nil
    }
    
    init(id: String, phoneNumber: String, name: String, avatar: String?){
        self.id = id
        self.phoneNumber  = phoneNumber
        self.name = name
        self.avatar = avatar
    }
    
}

extension FriendDomain : Searchable{
    func getKeyword() -> String {
        return name
    }
    
    
}

