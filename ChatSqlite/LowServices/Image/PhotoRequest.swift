//
//  FlickrPhotoStore.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit

enum PhotoError : Error {
    case imageCreationError
    case missingImageURL
    case brokenURL
}

class PhotoRequest{

    static let shared = PhotoRequest()
    init(){}
    
    private let session : URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchImage(url: URL) async throws -> UIImage{
//        let request = URLRequest(url: url)
        let (data, _) = try await session.data(from: url)
        return try await processImageRequest(data: data)
    }
    
    private func processImageRequest(data: Data) async throws -> UIImage {
        guard
            let image = UIImage(data: data) else {

                    throw PhotoError.imageCreationError
                }

        return image
    }
}
