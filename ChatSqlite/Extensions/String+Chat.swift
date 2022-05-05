//
//  String+Chat.swift
//  ChatSqlite
//
//  Created by LAP11353 on 19/04/2022.
//

import Foundation
extension String {

    func parse<D>(to type: D.Type) -> D? where D: Decodable {

        let data: Data = self.data(using: .utf8)!

        let decoder = JSONDecoder()

        do {
            let _object = try decoder.decode(type, from: data)
            return _object

        } catch {
            return nil
        }
    }
}
extension Notification.Name {

    static let onFinishCacheImageOfMessage = Notification.Name("on-finish-cache-image-of-message")
}
