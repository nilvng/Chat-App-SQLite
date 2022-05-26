//
//  NotificationViewController.swift
//  ChatNotiExtension
//
//  Created by LAP11353 on 24/05/2022.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.headerLabel?.text = notification.request.content.title
        self.bodyLabel?.text = notification.request.content.body
        self.imageView.image = UIImage(named: "default")
    }

}
