//
//  MediaWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 26/04/2022.
//

import UIKit
import Photos
enum ImageFileType {
    case original, thumbnail, both, avatar, rounded, video
    func types() -> [ImageFileType] {
        switch self {
        case .both:
            return [.thumbnail, .original]
        case .avatar:
            return [.original, .rounded]
        case .video:
            return [.thumbnail, .video]
        default:
            return [self]
        }
    }
    func getScaledSize(width: CGFloat, height: CGFloat) -> [CGSize]{
        switch self {
        case .original:
            return [UIScreen.main.bounds.size]
        case .thumbnail:
            var bubbleWidth : CGFloat = 210.0
            var scaledHeight = bubbleWidth * CGFloat(height / width)
            if scaledHeight < 70 {
               scaledHeight = 70
                bubbleWidth = scaledHeight * CGFloat(width / height)
            }
            return [CGSize(width: bubbleWidth, height: scaledHeight)]
        case .both:

            return [ImageFileType.original.getScaledSize(width: width, height: height)[0],
                    ImageFileType.thumbnail.getScaledSize(width: width, height: height)[0]]
        default:
            return []
        }
    }

    func getName(id: String) -> String {
        let fileExtension = ".jpg"
        let videoExension = ".mov"
        switch self {
        case .original:
            return id + "-fullsize" + fileExtension
        case .thumbnail:
            return id + "-thumbnail" + fileExtension
        case .both:
            return id + "-both" + fileExtension
        case .rounded:
            return id + "-rounded" + fileExtension
        case .video:
            return id + videoExension
        default:
            return id
        }
    }
}
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
//        let _ = try generateURL(filename: filename, folder: folder, isExisted: true)
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
            var filename = responseURL.lastPathComponent
            filename = folder != nil ? "\(folder!)/\(filename)" : filename
            if let targetURL = self.directory.appendPathComponent(filename) as? URL{
                let _ = FileManager.default.secureCopyItem(at: responseURL, to: targetURL)
            }
            
            
        }
    }

    func save(asset: PHAsset, folder: String?=nil, type: ImageFileType) async -> (im:UIImage,id:String){
        let types : [ImageFileType] = type.types()
        var im : UIImage = UIImage()
        
        let id = asset.localIdentifier.replacingOccurrences(of: "/", with: "-")
     
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
        
//        guard let directory = directory else {
//            fatalError()
//        }
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
