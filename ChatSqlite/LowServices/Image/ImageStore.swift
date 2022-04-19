//
//  CachedStore.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit

enum ImageType {
    case rounded
    case original
    
    func getImage(image: UIImage) -> UIImage{
        switch self {
        case .rounded:
            let im = makeRoundedImage(fullsizeImage: image)
            return im
        default:
            return image
        }
    }
    
    func makeRoundedImage(fullsizeImage: UIImage) -> UIImage{
        // create roundedImage from this fullsize image
        let size = CGSize(width: 70, height: 70) // proposed size
        let aspectWidth = size.width / fullsizeImage.size.width
        let aspectHeight = size.height / fullsizeImage.size.height

        let aspectRatio = max(aspectWidth, aspectHeight)

        let sizeIm = CGSize(width: fullsizeImage.size.width * aspectRatio, height: fullsizeImage.size.height * aspectRatio)
        let circleX = aspectWidth > aspectHeight ? 0 :  sizeIm.width/2 - sizeIm.height/2
        let circleY = aspectWidth > aspectHeight ? sizeIm.height/2 - sizeIm.width/2 : 0
        
        let renderer = UIGraphicsImageRenderer(size: sizeIm)
        return renderer.image { _ in
            UIBezierPath(ovalIn: CGRect(x: circleX,
                                                y: circleY,
                                                width: size.width,
                                                height: size.width)).addClip()
            fullsizeImage.draw(in: CGRect(origin: .zero, size: sizeIm))
        }
        
    }
}

class ImageConfig : NSObject{
    var urlString : String
    var type : ImageType
    
    
    init(url: String, type: ImageType) {
        self.urlString  = url
        self.type = type
    }
    
    
    func getFilename() -> String{
        if let url = URL(string: self.urlString){
            return url.lastPathComponent
        } else {
            return urlString
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
           guard let other = object as? ImageConfig else {
               return false
           }
           return urlString == other.urlString
               && type == other.type
       }
    
    override var hash: Int {
        return urlString.hash ^ type.hashValue
    }


    
}

actor ImageStore {
    
    let cache = NSCache<ImageConfig, UIImage>()
    let cacheSizeLimit = 4500000
    let photoRequest = PhotoRequest()
    
    static let shared = ImageStore()
    private init(){
        cache.totalCostLimit = 20
    }
        
    func setImage(_ image: UIImage, forKey key: ImageConfig, inMemOnly: Bool = true) -> UIImage{
        // Save in memory
        let img = key.type.getImage(image: image)
        
        cache.setObject(img, forKey: key)
        
        if !inMemOnly{
            // Save to disk
            /// Create full URL for image
            let url = imageURL(forKey: key.getFilename())
            
            /// Turn image into JPEG data
            if let data = image.jpegData(compressionQuality: 0.5) {
                try? data.write(to: url)
            }
            
        }
        // return correct image type
        return img
    }

    func getImage(forUrl urlKey: String, type: ImageType) async throws -> UIImage {
        // Case1: Find in memo
        let config = ImageConfig(url: urlKey, type: type)
        if let existingImage = cache.object(forKey: config) {
            return existingImage
        }
        // Case2: Find on disk
        let url = imageURL(forKey: config.getFilename())
        if let imageFromDisk = UIImage(contentsOfFile: url.path) {
            let image = self.setImage(imageFromDisk, forKey: config, inMemOnly: true)
            print("Found on disk..")
            return image
        }
        // Case3: Finally, request to the server
        print("From server")
        return try await getImageFromServer(forKey: urlKey, type: type)
    
        }

    func getImageFromServer(forKey key: String, type: ImageType) async throws -> UIImage {
        guard let remoteURL = URL(string: key) else {
            throw PhotoError.brokenURL
        }
        
        let im = try await photoRequest.fetchImage(url: remoteURL)
        let config = ImageConfig(url: key, type: type)
        let image = self.setImage(im, forKey: config,inMemOnly: false)
        return image
            
    }


    func deleteImage(forKey key: ImageConfig) {
        cache.removeObject(forKey: key)
        
        let url = imageURL(forKey: key.getFilename())
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    func imageURL(forKey key: String) -> URL {
        let documentsDirectories =
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!

        return documentDirectory.appendingPathComponent(key)
    }

    func clearCacheOnDisk(){
  
        // get folder size
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        var sizeOnDisk : Int?
        do {
            let cacheDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            sizeOnDisk = fileManager.directorySize(cacheDirectory)
            if sizeOnDisk != nil  {
                print("Size:", sizeOnDisk ?? -1) //
            }
        } catch {
            print("cannot get caches size on disk.")
        }
        // Actually clear cache
        do {
            /// Get the directory contents urls (including subfolders urls)
            var directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: [.contentAccessDateKey], options: [])
            /// sort item by its latest access date -> remove the oldest avatar only
            do{
            try directoryContents.sort(by: { (u1, u2) in
                let ua1  = try u1.resourceValues(forKeys:[.contentAccessDateKey])
                let ua2  = try u2.resourceValues(forKeys:[.contentAccessDateKey])
                return ua1.contentAccessDate! < ua2.contentAccessDate!
            }) } catch {
                print("Cannot sort cache file .. abort clearing")
                return
            }
            
            /// clear cache until meet the limit size
            for file in directoryContents {
                do {
                    // calculate amount if file/data to remove
                    guard let fileSize = file.fileSize else {
                        print("Cannot get size of this file: \(file)")
                        continue
                    }
                    if sizeOnDisk! - fileSize > self.cacheSizeLimit {
                        print("Remove file: \(file)")
                        try fileManager.removeItem(at: file)
                        sizeOnDisk! -= fileSize
                    } else {
                        break
                    }
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

extension URL {
    var fileSize: Int? { // in bytes
        do {
            let val = try self.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            return val.totalFileAllocatedSize ?? val.fileAllocatedSize
        } catch {
            print(error)
            return nil
        }
    }
}

extension FileManager {
    func directorySize(_ dir: URL) -> Int? { // in bytes
        if let enumerator = self.enumerator(at: dir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey], options: [], errorHandler: { (_, error) -> Bool in
            print(error)
            return false
        }) {
            var bytes = 0
            for case let url as URL in enumerator {
                bytes += url.fileSize ?? 0
            }
            return bytes
        } else {
            return nil
        }
    }
}
