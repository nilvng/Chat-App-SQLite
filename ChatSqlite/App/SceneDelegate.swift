//
//  SceneDelegate.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let sceneWindow = (scene as? UIWindowScene) else { return }
        let navController = UINavigationController(rootViewController: HomeModule().build())
        window = UIWindow(windowScene: sceneWindow)
        
        window?.rootViewController = navController
        let coordinator = ChatCoordinator(navVC: navController)
        ChatCoordinator.shared = coordinator
        window?.makeKeyAndVisible()

        //Handle Notification Response
            guard let notifiResponse = connectionOptions.notificationResponse else { return }
        let request = notifiResponse.notification.request
        let alert2 = UIAlertController(title: request.content.title,
                                       message: request.content.body, preferredStyle: .alert)
            let defaultAction2 = UIAlertAction(title: "OK", style: .default, handler: { action in
            })
        alert2.addAction(defaultAction2)
        
        if let cid = request.content.userInfo["cid"] as? String {
            openChatView(cid: cid)
        } else{
        window?.rootViewController?.present(alert2,animated: true)
        }

    }
    
    func openChatView(cid: String){
        ChatServiceManager.shared.getChatService(cid: cid, completion: { service in
            guard let service = service, let conv = service.conversatioNWorker.model else {
                return
            }
            ChatCoordinator.shared?.navigate(to: .chatView(model: conv))
        })
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

