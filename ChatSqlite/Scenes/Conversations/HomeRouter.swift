//
//  HomeRouter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 10/02/2022.
//

import Foundation
import UIKit

class HomeRouter {
    
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    weak var viewController : UIViewController?
    
    
    func showChats(for conv: ConversationDomain) {
        let view = ChatModule().build(for: conv)
        
        viewController?.show(view, sender: nil)
    }
    
    func showComposeView(){
        let view = FriendListViewController()
        viewController?.present(view, animated: true, completion: nil)
    }
}
