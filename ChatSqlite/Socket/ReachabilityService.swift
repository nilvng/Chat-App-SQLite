//
//  ReachabilityService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 02/03/2022.
//

import Foundation
import Alamofire
import Network

class ReachabilityService {
    let host = "www.google.com"
    var network : NetworkReachabilityManager?
    var monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    static let shared = ReachabilityService()
    
    init(){
        network = NetworkReachabilityManager(host: host)
    }
    
    func startNetworkObserver(){
        alamofireStart()

    }
    func networkStart(){
        monitor.pathUpdateHandler = { path in
            switch path.status {
            case .satisfied:
                DispatchQueue.main.async {
                    print("REACHABILITY: connected")
                }
            case .unsatisfied:
                print("REACHABILITY: not reachable")

            case .requiresConnection:
                print("REACHABILITY: require connection")

            @unknown default:
                print("REACHABILITY: unknown")

            }
            print(path.isExpensive) // is cellular
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    func alamofireStart(){
        network?.startListening(onUpdatePerforming: { status in
                   switch status {

                       case .notReachable:
                           print("REACHABILITY: not reachable")

                       case .unknown :
                           print("REACHABILITY: It is unknown")

                       case .reachable(.ethernetOrWiFi):
                           print("REACHABILITY: WiFi connection")

                       case .reachable(.cellular):
                           print("REACHABILITY: Cellular connection")

                       }
                   })
    }
}
