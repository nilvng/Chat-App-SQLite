//
//  FriendRouter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 14/02/2022.
//

import Foundation
import UIKit

class FriendRouter {
    weak var viewController : UIViewController?
    func toChatView(for friend : FriendDomain) {
        let view = ChatModule().build(for: friend)
        let presentingVC = viewController?.presentingViewController as? UINavigationController
        presentingVC?.pushViewController(view, animated: true)
        viewController?.dismiss(animated: false, completion: nil)
    }
    
    func toNewContactView(callback : @escaping (FriendDomain) -> Void){
        let addView = FriendDetailViewController()
        addView.configure(with: FriendDomain(), isNew: true, changeAction: callback)
        let presentingVC = viewController?.presentingViewController as? UINavigationController
        presentingVC?.pushViewController(addView, animated: true)
        viewController?.dismiss(animated: false, completion: nil)
    }
}
