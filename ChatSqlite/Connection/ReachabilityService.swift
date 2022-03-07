//
//  ReachabilityService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 02/03/2022.
//

import Foundation
import Alamofire

class ReachabilityService {
    let host = "https://33cb-2405-4803-c63d-bf00-2da2-751d-24e-49fa.ngrok.io"
//    let host = "www.google.com"
    var network : NetworkReachabilityManager?
    
    static let shared = ReachabilityService()
    
    init(){
        network = NetworkReachabilityManager(host: host)
    }
    
    func startNetworkObserver(){
        alamofireStart()
    }
    
    func notifyDisconnect(msg: String){
        NotificationCenter.default.post(name: .networkChanged,
                                        object: self,
                                        userInfo: ["msg": msg])
    }

    func alamofireStart(){
        network?.startListening(onUpdatePerforming: { status in
                   switch status {

                       case .notReachable:
                           print("REACHABILITY: not reachable")
                       self.notifyDisconnect(msg: "Waiting for network")

                       case .unknown :
                           print("REACHABILITY: It is unknown")
                       self.notifyDisconnect(msg: "Waiting for network")

                       case .reachable(.ethernetOrWiFi):
                           print("REACHABILITY: WiFi connection")
                       self.notifyDisconnect(msg: "Network is back")

                       case .reachable(.cellular):
                           print("REACHABILITY: Cellular connection")
                       self.notifyDisconnect(msg: "Network is back")

                       }
                   })
    }
}
