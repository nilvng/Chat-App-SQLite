//
//  ChatRouter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 10/02/2022.
//

import UIKit

class ChatRouter : NSObject {
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    weak var viewController : UIViewController?
    var transition : PopAnimator?

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
    
    func toMediaView(i: Int, of message: MessageDomain){
        let photoVC = MediaViewController()
        photoVC.transitioningDelegate = self
        photoVC.configure(i: i, of: message)
        photoVC.modalPresentationStyle = .fullScreen
        viewController?.present(photoVC, animated: true)
    }
}
// MARK: - TransitionDelegate
extension ChatRouter : UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let second = presented as? PopAnimatableViewController,
              let first = viewController as? PopAnimatableViewController else {
                  return nil
              }
        transition = PopAnimator(presenting: true, firstVC: first, secondVC: second)
        return transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let second = dismissed as? PopAnimatableViewController,
              let first = viewController as? PopAnimatableViewController else {
                  return nil
              }
        transition = PopAnimator(presenting: false, firstVC: first, secondVC: second)
        return transition
    }
}
