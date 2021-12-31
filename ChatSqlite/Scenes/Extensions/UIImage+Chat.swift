//
//  UIButton+Chat.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

extension UIImage {
    static let btn_send_forboy = UIImage(named: "btn_send_forboy")?.withRenderingMode(.alwaysTemplate)
    static let btn_send_forboy_disabled = UIImage(named: "btn_send_forboy_disable")?.withRenderingMode(.alwaysTemplate)
    static let chat_menu = UIImage(named: "icHeaderList")
    static let back_button = UIImage(named: "icn_navigation_button_back_white")

    static let navigation_search = UIImage(named: "icn_navigation_button_search")
    static let navigation_search_selected = UIImage(named: "icn_navigation_button_search_selected")
    
    static let navigation_button_plus = UIImage(named: "navigation_button_plus")
    static let navigation_button_plus_selected = UIImage(named: "navigation_button_plus_selected")
    
    static let compose_message = UIImage(named: "compose_message")
    static let new_contact = UIImage(named: "NewContact")
    static let new_group_chat = UIImage(named: "NewGroupChat")

}

extension UIImage{
    func resizedImage(size: CGSize) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

    }
}
