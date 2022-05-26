//
//  ChatCoordinator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 24/05/2022.
//

import Foundation
import UIKit

class ChatCoordinator {
    
    static var shared : ChatCoordinator?
    
    enum Destination{
        case chatView(model: ConversationDomain)
    }

    var navVC : UINavigationController
    
    internal init(navVC: UINavigationController) {
        self.navVC = navVC
    }
    
    func navigate(to destination: Destination) {
        DispatchQueue.main.async {
            let viewController = self.makeViewController(for: destination)
            self.navVC.pushViewController(viewController, animated: true)
            }
        }
    
    private func makeViewController(for destination: Destination) -> UIViewController {
            switch destination {
            case .chatView(let model):
                return ChatModule().build(for: model)
            }
        }
    
}
