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
    var transition = PopAnimator()
    var mediaOriginFrame = CGRect.zero

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
    
    func toMediaView(i: Int, of message: MessageDomain,
                     from fromController: UICollectionView){
        let photoVC = MediaViewController()
        photoVC.transitioningDelegate = self
        photoVC.configure(i: i, of: message)

        // get original frame
        guard let selectedIndexPath = fromController.indexPathsForSelectedItems?.first,
              let selectedCell = fromController.cellForItem(at: selectedIndexPath),
        let selectedSuperView = selectedCell.superview else{
                  return
              }
        let bubbleFrame = selectedSuperView.convert(selectedCell.frame, to: nil)

        mediaOriginFrame = bubbleFrame
        
//        mediaOriginFrame = CGRect(x: mediaOriginFrame.origin.x + 20, y: mediaOriginFrame.origin.y + 20, width: mediaOriginFrame.size.width - 40, height: mediaOriginFrame.size.height - 40)
        mediaOriginFrame = CGRect(x: mediaOriginFrame.origin.x, y: mediaOriginFrame.origin.y, width: mediaOriginFrame.size.width, height: mediaOriginFrame.size.height)
        
        self.viewController?.present(photoVC, animated: true, completion: nil)
    }
}
// MARK: - TransitionDelegate
extension ChatRouter : UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.originalFrame = mediaOriginFrame
        return transition
    }
}
