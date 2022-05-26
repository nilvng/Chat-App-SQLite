//
//  NotificationManager.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/05/2022.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager : NSObject {
    var center  = UNUserNotificationCenter.current()
    var chatManager : ChatServiceManager = ChatServiceManager.shared
    struct Category {
        static let message = "Message"
    }
    struct Action {
        static let reply = "Reply"
        static let like = "like"
    }
    
    override init(){
        super.init()
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            if notificationSettings.authorizationStatus  == .authorized {
                self.configure()
            }
        }
        center.delegate = self
    }
    // MARK: - Publish Noti
    func publishNewMessageNoti(text: String,
                               from who: String,
                               cid: String){
        let content = UNMutableNotificationContent()
        content.title = who
        content.body = text
        content.categoryIdentifier = NotificationManager.Category.message
        content.userInfo["cid"] = cid
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        // Schedule the request with the system.
        
        center.add(request) { (error) in
           if error != nil {
               print("error from Notification")
              // Handle any errors.
           }
        }
    }
    
    
    // MARK: -Configure Actions
    func configure(){
        configureMessageNoti()
    }
    
    func configureMessageNoti(){
        let likeAction = UNNotificationAction(identifier: Action.like,
                                              title: "Like",
                                              options: [])
        let replyAction = UNTextInputNotificationAction(identifier: Action.reply, title: "Reply", options: [.authenticationRequired])
        
        let category = UNNotificationCategory(identifier: Category.message, actions: [likeAction, replyAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
    }
    
    func handleUserInput(response: UNTextInputNotificationResponse){
        let text = response.userText
        guard let cid = response.notification.request.content.userInfo["cid"] as? String else{
            return
        }
        let m = MessageDomain(cid: cid, content: text, type: .text, status: .sent, downloaded: false)
        chatManager.sendMessage(msg: m, completion: { working in
            print("\(self) successfully send msg")
        })
    }

}

extension NotificationManager : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return .banner
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("I'm here")
        let userInfo = response.notification.request.content.userInfo
        let categoryID = response.notification.request.content.categoryIdentifier
        let convID = userInfo["cid"] as! String
        if categoryID == Category.message {
            switch response.actionIdentifier {
            case Action.like:
                print("likey")
                openChatView(cid: convID)
            case Action.reply:
                guard let textResponse = response as? UNTextInputNotificationResponse else {
                    fatalError()
                }
                //send to ChatService
                print("Request to send msg: \(textResponse.userText) to \(convID)")
                self.handleUserInput(response: textResponse)
                
            case UNNotificationDismissActionIdentifier, UNNotificationDefaultActionIdentifier:
                openChatView(cid: convID)
            default:
                break
            }
        }
        completionHandler()
    }
    
    func openChatView(cid: String){
        chatManager.getChatService(cid: cid, completion: { service in
            guard let service = service else {
                return
            }
            let conv = service.conversatioNWorker.model!
            ChatCoordinator.shared?.navigate(to: .chatView(model: conv))
        })
    }

}
