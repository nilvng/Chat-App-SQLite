//
//  UserSettings.swift
//  ChatSqlite
//
//  Created by LAP11353 on 03/03/2022.
//

import Foundation

struct UserSettings {
    static let shared = UserSettings()
    
    func getUserID() -> String {
        let user = UserDefaults.standard
        return user.string(forKey: "UserID") ?? "1"
    }
    
    func setUserID(uid: String) {
        let user = UserDefaults.standard
        user.set(uid, forKey: "UserID")
    }
    
}
