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
    
    var name: String {
        didSet {
            let arr  = name.components(separatedBy: .whitespacesAndNewlines)
            if arr.count > 1 {
            firstName = arr[0]
            }
            if arr.count > 2 {
            lastName = arr[1]
            }
        }
    }
    
    var firstName: String?
    var lastName: String?
    
    init(){
        id = ""
        phoneNumber = ""
        name = "D"
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

