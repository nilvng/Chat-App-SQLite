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
    
    func fetchImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void){
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request){ (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)

            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> (Result<UIImage, Error>) {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {

                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }

        return .success(image)
    }
}
