//
//  MessagesModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation
import Alamofire
import UIKit

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
    
    var images : [UIImage] = []
    var urls : [URL] = []

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
    
    func encodeImageUrls(_ urls: [String]){
        self.content = ""
        for u in urls {
            self.content += "\(u)|"
        }
    }
    
    func getImageURL(index: Int) -> URL? {
        let urls = self.content.components(separatedBy: "|")
        guard urls.count >= index else {
            return nil
        }
        let filename = urls[index]
        var documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl.appendingPathComponent(filename)
    }

}

extension MessageDomain {
    func encodeSocketFormat() -> String{
        return "\(cid)\(sender)\(mid)\(content)"
    }
}
