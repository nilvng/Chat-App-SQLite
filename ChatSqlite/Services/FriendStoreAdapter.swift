//
//  FriendsStoreAdapter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation

class FriendStoreAdapter {
    var adaptee : FriendSQLiteStore
    
    init(adaptee: FriendSQLiteStore){
        self.adaptee = adaptee
    }
}
