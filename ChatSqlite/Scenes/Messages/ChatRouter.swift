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
        let vc = GalleryContainerViewController()
        vc.callback  =  { assets in
            guard let viewController = self.viewController as? ChatViewController else {
                return
            }
            viewController.interactor?.doneSelectLocalMedia(assets)
        }
        vc.modalPresentationStyle = .pageSheet
        if let presentation  = vc.sheetPresentationController {
            presentation.detents = [.medium(), .large()]
            presentation.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        viewController?.present(vc, animated: true, completion: nil)
    }
}
