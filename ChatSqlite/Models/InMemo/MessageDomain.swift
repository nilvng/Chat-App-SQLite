//
//  MessagesModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation
import Alamofire

class MessageDomain {
    
    var mid : String

    var cid: String
    
    var content: String
    
    var type: MessageType
    
    var timestamp: Date
    
    var sender: String
    
    var downloaded : Bool = false
    var status : MessageStatus = .sent
 
    // download subscriber
    var subscriber : MessageSubscriber?
    
    init(mid: String, cid: String, content: String, type: MessageType, timestamp: Date, sender: String, downloaded: Bool = false, status: MessageStatus) {
        self.mid = mid
        self.cid = cid
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.sender = sender
        self.downloaded = downloaded
        self.status = status
    }
    init(cid: String, content: String, type: MessageType, status: MessageStatus,downloaded: Bool = false) {
        self.mid = UUID().uuidString
        self.cid = cid
        self.content = content
        self.type = type
        self.timestamp = Date()
        self.sender = UserSettings.shared.getUserID()
        self.downloaded = downloaded
        self.status = status
    }
    
    func isFromThisUser() -> Bool{
        return self.sender == UserSettings.shared.getUserID()
    }
    
}

extension MessageDomain {
    func download(sub : MessageSubscriber? = nil){
        if sub != nil{
            self.subscriber = sub
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        AF
            .download(content, to: destination)
            .downloadProgress { [self] progress in
                let val = progress .fractionCompleted
                subscriber?.progressTo(val: val)
                                
            }
            .responseURL { [self] file in
                downloaded = true
                //ChatManager.shared.updateMsg(self)
                print("download file to: \(file)")
            }
    }
    
    func dropSubscriber(){
        subscriber = nil
    }
    
    func subscribe(_ sr : MessageSubscriber){
        subscriber = sr
    }

}

extension MessageDomain {
    func encodeSocketFormat() -> String{
        return "\(cid)\(sender)\(mid)\(content)"
    }
}
