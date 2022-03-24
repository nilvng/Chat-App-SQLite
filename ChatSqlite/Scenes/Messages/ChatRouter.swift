//
//  ChatRouter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 10/02/2022.
//

import UIKit

class ChatRouter {
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    weak var viewController : UIViewController?
    
    func toMenuScreen(conversation: ConversationDomain){
        let view = ChatMenuController()
        view.configure(conversation)
        viewController?.show(view, sender: nil)
    }
    func toPhotoGallery(){
        let view = PhotoCollectionViewController()
        viewController?.show(view, sender: nil)
    }
}
