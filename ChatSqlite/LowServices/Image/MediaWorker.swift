//
//  MediaWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 26/04/2022.
//

import UIKit
import Photos

class MediaWorker {
    var imageStore : ImageStore = ImageStore.shared
    static let shared = MediaWorker()
    var directory : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let options : PHImageRequestOptions = {
        let op = PHImageRequestOptions()
        op.isNetworkAccessAllowed = true
        op.deliveryMode = .highQualityFormat
        op.resizeMode = .fast
        return op
    }()
    
    func image(index: Int, of msg: MessageDomain, type: ImageFileType) async throws -> UIImage? {
        guard let id = msg.getPrep(index: index)?.imageID else {
            throw PhotoError.missingImageURL
        }
        return try await image(name: id, folder: msg.cid, type: type)
    }
    func image(name: String, folder: String?=nil, type: ImageFileType) async throws -> UIImage?{
        var filename = type.getName(id: name)
        if let f = folder {
            filename = f + "/" + filename
        }
        let config = ImageConfig(url: filename, type: type, source: .local, storage: .document)
        return try await imageStore.getImage(config: config)

    }
    
    func saveVideo(asset: PHAsset, folder: String?=nil){
        asset.getURL { responseURL in
            guard let responseURL = responseURL else {
                return
            }
            var filename : String = responseURL.lastPathComponent
            filename = folder != nil ? "\(folder!)/\(filename)" : filename
            print(self.directory.appendingPathComponent(filename))
            let targetURL = self.directory.appendingPathComponent(filename)
            print("New video on: \(targetURL.path)")
            let _ = FileManager.default.secureCopyItem(at: responseURL, to: targetURL)
            
        }
    }
    
    func url(index: Int, of msg: MessageDomain, isExist : Bool) -> URL?{
        let folder = msg.cid
        
        if var filename = msg.getPrep(index: index)?.imageID{
            var mediaType = ImageFileType.original
            if msg.mediaPreps?[index].type == .video {
                mediaType = .video
            }
            filename = mediaType.getName(id: filename)
            let url = try? generateURL(filename: filename, folder: folder,
                                       isExisted: isExist)
            return url
        }
        return nil
    }
    func saveImageForVideo(asset: PHAsset, filename: String, folder: String?=nil){
        
    }
    
    func save(asset: PHAsset, filename: String, folder: String?) {
        
    }

    func save(asset: PHAsset, folder: String?=nil, type: ImageFileType) async throws -> (im:UIImage,id:String){
        
        var id : String = ""

        if type == .video {

            var videoURL = try await asset.getURL()
            videoURL = videoURL.deletingPathExtension()
            id = videoURL.lastPathComponent
            
        } else {
            id = asset.localIdentifier.replacingOccurrences(of: "/", with: "-")

        }
        let types : [ImageFileType] = type.types()
        var im : UIImage = UIImage()
        
        for t in types {
            let targetSize : CGSize = t.getScaledSize(width: CGFloat(asset.pixelWidth),
                                                      height: CGFloat(asset.pixelHeight))[0]
            
            var filename = t.getName(id: id)
            
            guard let targetURL : URL = try? generateURL(filename: filename,
                                                   folder: folder, isExisted: false) else {
                fatalError()
            }
            
            guard let image = try? await PHImageManager.default().requestImage(for: asset, targetSize: targetSize,
                            contentMode: .aspectFit, options: options) else {
                fatalError()
            }

            
            if let f = folder{
                filename = f + "/" + filename
            }
            let config = ImageConfig(url: filename,
                                     type: type,
                                     source: .local,
                                     storage: .document)
            let _ = await self.imageStore.setImage(image, forKey: config, inMemOnly: false)
            im = image
            
        }
        return (im, id)
    }
    
    func backgroundColor(image: UIImage) -> (r: Int, b: Int, g: Int, a: Int)?{
        return image.averageColorRGBA
    }

    private func generateURL(filename: String, folder: String?=nil, isExisted: Bool = true) throws -> URL {
        /*
         1. create path based on given a filename and folder name
         2. validate the newly-created path
         3. return the path
         */

        let fileManager = FileManager.default
        
        var target = ""
        if let folder = folder {
            target = "\(folder)/\(filename)"
            let userFolder = directory.appendingPathComponent(folder)
            // if given foldername not exist, create that folder
            if (!fileManager.fileExists(atPath: userFolder.path)) {
                try fileManager.createDirectory(atPath: userFolder.path,
                                                withIntermediateDirectories: false, attributes: nil)
            }
            
        } else {
            target = "\(filename)"
        }
        
        
        let targetURL = directory.appendingPathComponent(target)
        
        
        // create directory that store all media files of the user/conversation
        if FileManager.default.fileExists(atPath: targetURL.path) && !isExisted{
            try FileManager.default.removeItem(at: targetURL)
        }
        
        
        return targetURL
    }
    
}
extension FileManager {

    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

}
