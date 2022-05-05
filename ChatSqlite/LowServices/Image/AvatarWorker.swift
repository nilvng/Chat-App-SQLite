//
//  AvatarWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 26/04/2022.
//

import Foundation
import UIKit

class AvatarWorker {
    var imageStore : ImageStore = ImageStore.shared
    let photoRequest = PhotoRequest()
    static let shared = AvatarWorker()
    
    func load(url: String, type: ImageFileType = .rounded) async -> UIImage?{
        var config = ImageConfig(url: url, type: type, source: .remote, storage: .cache)
        // can't find in local storage
        guard let im = try? await imageStore.getImage(config: config) else{
            // try to fetch image from remote server
            if var im = try? await getImageFromServer(url: url){
                if type == .rounded {
                    im = im.rounded()
                    im = await imageStore.setImage(im, forKey: config, inMemOnly: false)
                    return im
                }
                return im
            }
            return nil
        }
        return im
    }
    
    func getImageFromServer(url key: String) async throws -> UIImage {
        guard let remoteURL = URL(string: key) else {
            throw PhotoError.brokenURL
        }
        
        let im = try await photoRequest.fetchImage(url: remoteURL)
        return im
            
    }
}
