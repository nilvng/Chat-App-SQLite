//
//  ChatRouter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 07/02/2022.
//

import Foundation
import UIKit

class AppRouter : NSObject{
    static var shared = AppRouter()
    var window: UIWindow?
    
    var rootViewController: UIViewController {
        guard let first = navigationStack.first else {
            fatalError("There must always be at least one navigation controller")
        }
        return first
    }
    
    private var navigationStack: Array<UINavigationController>
    private var currentNavigationController: UINavigationController {
        guard let top = navigationStack.last else {
            fatalError("There must always be a navigation controller on the stack")
        }
        return top
    }
    private override init(){
        navigationStack = [UINavigationController(navigationBarClass: nil, toolbarClass: nil)]

        super.init()

    }
    
    func start(sceneWindow: UIWindowScene){
        if window == nil {
            window = UIWindow(windowScene: sceneWindow)
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        }
        toHomepage()
    }
    
    func toComposePage(){
        let page = FriendListViewController()
        showViewController(page)
    }
    
    func toHomepage(){
        let conv = HomeModule().build()
        showViewController(conv)
    }
    
    func toChatMenuPage(){
        let chatMenu = ChatMenuController()
        //chatMenu.setup(interactor: MessagesMediator())
        showViewController(chatMenu)
    }
    func navigateBack(from vc: UIViewController){
        hideViewController(vc)
    }
    
    func showViewController(_ vc: UIViewController) {
        let current = currentNavigationController
        
        if vc is UIAlertController {
            current.present(vc, animated: true, completion: nil)
        } else {
            let animated = current.children.isEmpty == false
            current.pushViewController(vc, animated: animated)
        }
    }
    
    func hideViewController(_ vc: UIViewController) {
        let current = currentNavigationController
        let stack = current.children
        if let index = stack.firstIndex(of: vc) {
            let newStack = Array(stack[0..<index])
            currentNavigationController.setViewControllers(newStack, animated: true)
        }
    }

}
extension UIWindow {
    
    convenience init(rootViewController: UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        self.rootViewController = rootViewController
        self.makeKeyAndVisible()
    }
    
}
