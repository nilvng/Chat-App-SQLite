//
//  MessagesModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation
import Alamofire
import UIKit
import Photos
import SQLite


struct MediaPrep : Codable{
    var imageID: String
    var width : Int
    var height: Int
    var bgColor: ColorRGB?
    var type: MediaType = .photo
}

enum MediaType : Int,Codable{
    case photo, video
}

struct ColorRGB : Codable{
    var red: Int
    var green : Int
    var blue: Int
    var alpha: Int
}

class MessageDomain {
    
    var mid : String

    var cid: String
    
    var content: String {
        didSet {
            if type == .image {
                parseToUrls()
            }
        }
    }
    
    var type: MessageType
    
    var timestamp: Date
    
    var sender: String
    
    var downloaded : Bool = false
    var status : MessageStatus = .sent
    var urls : [String] = []
    
    var mediaPreps : [MediaPrep]?
    // download subscriber
    var subscriber : MessageSubscriber?
    
    init(mid: String, cid: String, content: String, type: MessageType, timestamp: Date, sender: String, downloaded: Bool = false, status: MessageStatus, mediaPreps: [MediaPrep]?=nil) {
        self.mid = mid
        self.cid = cid
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.sender = sender
        self.downloaded = downloaded
        self.status = status
        self.mediaPreps = mediaPreps
    }
    init(cid: String, content: String="", type: MessageType,
         status: MessageStatus = .sent,
         downloaded: Bool = false) {
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

    func parseToUrls(){
        urls = self.content.components(separatedBy: "|")
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
    
    func encodeImageUrls(_ urls: [String]){
        self.content = ""
        for u in urls {
            self.content += "\(u)|"
        }
    }
    
    func getImageURL(index: Int) -> URL? {
        if urls.count == 0 {
            urls = self.content.components(separatedBy: "|")
        }
        guard urls.count >= index else {
            return nil
        }
        let filename = urls[index]
        print(filename)
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl.appendingPathComponent(filename)
    }
    func getImageID(index: Int) -> String? {
        if urls.count == 0 {
            urls = self.content.components(separatedBy: "|")
        }
        guard urls.count >= index else {
            return nil
        }
        let filename = urls[index]
        return filename
    }
    
    func getPrep(index: Int) -> MediaPrep? {
 
        guard mediaPreps != nil && mediaPreps!.count > index else {
            return nil
        }
        return mediaPreps?[index]
    }

    
    func setContent(urlString: [String]){
        content = urlString.joined(separator: "|")
        print(content)
    }
}

extension MessageDomain {
    
    func setPreps(assets: [PHAsset]) async throws{
        
        var preps : [MediaPrep] = []
        
        for asset in assets {
            var id: String
            var type : MediaType = .photo
            
            // Get ID
            if asset.mediaType == .video {
                type = .video
                var videoURL = try await asset.getURL()
                videoURL = videoURL.deletingPathExtension()
                id = videoURL.lastPathComponent
                
            } else {
                id = asset.localIdentifier.replacingOccurrences(of: "/", with: "-")
                
            }
            let options : PHImageRequestOptions = {
                let op = PHImageRequestOptions()
                op.isNetworkAccessAllowed = true
                op.deliveryMode = .fastFormat
                op.resizeMode = .fast
                return op
            }()
            // Get background color
            let im = try await PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 10, height: 10), contentMode: .aspectFill, options: options)
            let bgColor = im.averageRGBA
            
            let prep = MediaPrep(imageID: id,
                                 width: asset.pixelWidth,
                                 height: asset.pixelHeight, bgColor: bgColor,
                                 type: type)
            preps.append(prep)
        }
        
        self.mediaPreps = preps
        
    }
    
    func getPrepColor(i: Int) -> UIColor?{
        guard let prep = getPrep(index: i) else {
            return nil
        }
        if let colorRGB = prep.bgColor {
            return UIColor(red: CGFloat(colorRGB.red),
                               green: CGFloat(colorRGB.green),
                               blue: CGFloat(colorRGB.blue),
                               alpha: CGFloat(colorRGB.alpha))
        }
        return nil
    }
}

extension MessageDomain {
    func encodeSocketFormat() -> String{
        return "\(cid)\(sender)\(mid)\(content)"
    }
}
