//
//  CachedStore.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit

enum ImageSource {
    case remote, local
}
class ImageConfig : NSObject{
    var urlString : String
    var type : ImageFileType
    var source : ImageSource
    var storageFolder: StorageFolder
    
    init(url: String, type: ImageFileType, source: ImageSource = .remote, storage: StorageFolder = .cache) {
        self.urlString  = url
        self.type = type
        self.source = source
        self.storageFolder = storage
    }

    
    func localFileName() -> String{
        if source == .remote, let url = URL(string: self.urlString){
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

enum StorageFolder{
    case cache, document
    
    func dir() -> FileManager.SearchPathDirectory{
        switch self {
        case .cache:
            return .cachesDirectory
        case .document:
            return .documentDirectory
        }
    }
}
actor ImageStore {

    
    let cache = NSCache<ImageConfig, UIImage>()
    let cacheSizeLimit = 4500000
    
    static let shared = ImageStore()
    private init(){
        cache.totalCostLimit = 20
    }
        
    func setImage(_ image: UIImage,
                  forKey key: ImageConfig,
                  inMemOnly: Bool = true) -> UIImage{
        // Save in memory
        if cache.object(forKey: key) == nil {
            // reentrancy problem
            cache.setObject(image, forKey: key)
        }
        
        if !inMemOnly{
            // Save to disk
            /// Create full URL for image
            let url = imageURL(forKey: key.localFileName(),
                               storage: key.storageFolder)
            let quality : CGFloat = key.type == .original ? 1.0 : 1.0
            /// Turn image into JPEG data
            if let data = image.jpegData(compressionQuality: quality) {
                try? data.write(to: url)
            }
            
        }
        return image
    }
    
    func getImage(config: ImageConfig) async throws -> UIImage? {
        // Case1: Find in memo
        if let existingImage = cache.object(forKey: config) {
            return existingImage
        }
        // Case2: Find on disk
        let url = imageURL(forKey: config.localFileName(),
                           storage: config.storageFolder)
        if let imageFromDisk = UIImage(contentsOfFile: url.path) {
            let image = self.setImage(imageFromDisk, forKey: config, inMemOnly: true)
            print("Found on disk..")
            print(url.path)
            return image
        }
        
        return nil

    }

    func deleteImage(forKey key: ImageConfig) {
        cache.removeObject(forKey: key)
        
        let url = imageURL(forKey: key.localFileName(), storage: key.storageFolder)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    let imageExtension = ".jpg"
    
    func imageURL(forKey key: String, storage: StorageFolder) -> URL {

        let dir = storage.dir()
        let documentsDirectories =
            FileManager.default.urls(for: dir, in: .userDomainMask)
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
