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
    static let shared : NotificationManager? = NotificationManager()
    
    var center  = UNUserNotificationCenter.current()
    var handlers : [String: ActionHandler] = [:]
    var chatManager : ChatServiceManager = ChatServiceManager.shared
    struct Category {
        static let message = "Message"
    }
    struct Action {
        static let reply = "Reply"
        static let like = "like"
        static let messageDefault = "msgDefault"
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
        
        handlers[Action.reply] = MessageReplyHandler()
        handlers[Action.messageDefault] = MessageDefaultHandler()
        
        center.setNotificationCategories([category])
    }
    
    func didReceive(response : UNNotificationResponse){
        let categoryID = response.notification.request.content.categoryIdentifier
            
            switch response.actionIdentifier {
            case Action.like:
                handlers[Action.messageDefault]?.execute(response: response)
            case Action.reply:
                handlers[Action.reply]?.execute(response: response)
                
            case UNNotificationDismissActionIdentifier, UNNotificationDefaultActionIdentifier:
                if categoryID == Category.message{
                    handlers[Action.messageDefault]?.execute(response: response)
                }
            default:
                break
        }
    }

}

extension NotificationManager : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return .banner
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        self.didReceive(response: response)
        
        completionHandler()
    }
}
