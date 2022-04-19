//
//  LocalMediaWorker.swift
//  ChatSqlite
//
//  Created by LAP11353 on 12/04/2022.
//

import Foundation
import Photos
import PhotosUI
import UIKit
enum ImageFileType {
    case fullsize, thumbnail
    func getScaledSize(width: CGFloat, height: CGFloat) -> CGSize{
        switch self {
        case .fullsize:
            return UIScreen.main.bounds.size
        case .thumbnail:
            let bubbleWidth : CGFloat = 210.0
            let scaledHeight = bubbleWidth * CGFloat(height / width)
            return CGSize(width: bubbleWidth, height: scaledHeight)
        }
    }
    
    func getName(id: String) -> String {
        switch self {
        case .fullsize:
            return id + "-fullsize"
        case .thumbnail:
            return id + "-thumbnail"
        }
    }
}

actor LocalMediaWorker {
    static let shared = LocalMediaWorker()
    let directory : URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let cache = NSCache<NSString, UIImage>()

    func saveVideo(){
        
    }
    private init(){}
    
    func loadImage(id: String, folder: String?=nil) throws -> UIImage {
        let fileURL = generateURL(filename: id, folder: folder, isExisted: true)
        let imageData = try Data(contentsOf: fileURL)
        guard let im =  UIImage(data: imageData) else {
            throw PhotoError.imageCreationError
        }
        cache.setObject(im, forKey: fileURL.lastPathComponent as NSString)
        return im
      
    }
    
    func scale(image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image{ _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

    }
    func scale(image exist: UIImage, imageType: ImageFileType) -> UIImage{
        let h = exist.size.height
        let w = exist.size.width
        let wantedSize = imageType.getScaledSize(width: w, height: h)
        let wantedImage = scale(image: exist, size: wantedSize)
        return wantedImage
    }
    
    func getImage(index: Int, of msg: MessageDomain, type: ImageFileType) async throws -> UIImage {
        guard let id = msg.getImageID(index: index) else {
            throw PhotoError.missingImageURL
        }
        if let im = try await getCachedImage(key: id, imageType: type){
            print(im)
            return im
        }
        let id_name = ImageFileType.fullsize.getName(id: id)
        print("loading image from storage...\(id_name)")
        let im = try loadImage(id: id_name, folder: msg.cid)
        return im
        
    }
    
    
    func getCachedImage(key: String, imageType: ImageFileType) async throws -> UIImage?{
        let realKey = imageType.getName(id: key)
        if let exist = cache.object(forKey: realKey as NSString) {
            return exist
        }
        if imageType != .fullsize {
            // try to find full size and scale down image
            let secondKey = ImageFileType.fullsize.getName(id: key)
            // fullsize exists
            if let exist = cache.object(forKey: secondKey as NSString) {
                let wantedImage = scale(image: exist, imageType: imageType)
                cache.setObject(wantedImage, forKey: realKey as NSString)
                return wantedImage
            }
            
            // not exist, load from storage
        }
        return nil
    }
    
    func savePhoto(asset: PHAsset, folder: String?=nil, type: ImageFileType = .fullsize) async throws -> String
    {
        let id = getUID()
        
        var types : [ImageFileType] = []
//        if type == .both {
//            types = [.thumbnail, .fullsize]
//        } else {
//            types = [type]
//        }
        let t = ImageFileType.fullsize
//        for t in types {
        let targetSize : CGSize = t.getScaledSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            let filename = "\(t.getName(id: id)).jpg"
            let targetURL = generateURL(filename: filename, folder: folder, isExisted: false)

        let im = try await self.savePhoto(asset: asset, targetSize: targetSize, targetURL: targetURL)
        if cache.object(forKey: targetURL.lastPathComponent as NSString) == nil {
            // reentrancy problem
            cache.setObject(im, forKey: targetURL.lastPathComponent as NSString)
        }
//        }
        return id
        
    }
    
    func savePhoto(asset: PHAsset, targetSize: CGSize, targetURL: URL) async throws -> UIImage {
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        let image = try await PHImageManager.default().requestImage(for: asset, targetSize: targetSize,
                                                 contentMode: .aspectFit, options: options)
        guard let data = image.jpegData(compressionQuality: 1) else { throw PhotoError.imageCreationError }
        try data.write(to: targetURL)
        return image
    
    }
    
    func savePhoto(from localURL: URL, id: String, folder: String?){
        let filename = "\(id).\(localURL.pathExtension)"
        let targetURL = generateURL(filename: filename, folder: folder)
        savePhoto(from: localURL, to: targetURL)
    }
    func savePhoto(from url: URL ,to targetURL: URL){
        
        do{
            try FileManager.default.copyItem(at: url, to: targetURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func generateURL(filename: String, folder: String?=nil, isExisted: Bool = true) -> URL {
        /*
         1. create path based on given a filename and folder name
         2. validate the newly-created path
         3. return the path
         */
        
        guard let directory = directory else {
            fatalError()
        }
        let fileManager = FileManager.default

        var target = ""
        var extensionPath  = "jpg"
        if let folder = folder {
            target = "\(folder)/\(filename)"
            let userFolder = directory.appendingPathComponent(folder)
            do {
                // if given foldername not exist, create that folder
                if (!fileManager.fileExists(atPath: userFolder.path)) {
                    try fileManager.createDirectory(atPath: userFolder.path,
                                                    withIntermediateDirectories: false, attributes: nil)
                }} catch let e {
                    fatalError()
                }

        } else {
            target = "\(filename)"
        }
        
        target += ".\(extensionPath)"

        let targetURL = directory.appendingPathComponent(target)
        

        do {
            // create directory that store all media files of the user/conversation
            if FileManager.default.fileExists(atPath: targetURL.path) && !isExisted{
                try FileManager.default.removeItem(at: targetURL)
            }
        } catch let e {
            fatalError()
        }
            
        return targetURL
    }
    
    func getUID() -> String{
//        ret urn UUID().uuidString
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let length = 4
        var randomString: String = ""
        for _ in 0..<length {
            let randomNumber = Int.random(in: 0..<letters.count)
            randomString.append(letters[randomNumber])
        }
        return randomString
    }
}
