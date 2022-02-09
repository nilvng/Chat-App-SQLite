//
//  ImageService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 12/01/2022.
//

import UIKit
import Alamofire

protocol MessageSubscriber {
    func progressTo(val : Double)
}

class FileDownloader{
    let shared = FileDownloader()
    
    func download(_ url : String, subscriber sub: MessageSubscriber? = nil){
        var subscriber : MessageSubscriber? = nil
        if sub != nil{
            subscriber = sub
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        AF
            .download(url, to: destination)
            .downloadProgress { progress in
                let val = progress .fractionCompleted
                subscriber?.progressTo(val: val)
                                
            }
            .responseURL { file in
                print("download file to: \(file)")
            }
    }
}
