//
//  PhotoView.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/04/2022.
//

import UIKit


@MainActor class PhotoView : UIImageView {
    lazy var worker : MediaWorker = MediaWorker.shared
    var id: String!
    
    func load(filename: String, folder: String?=nil,
              type: ImageFileType,
              backgroundColor: UIColor? = .trueLightGray){ // TODO: generalize this function load(URL:)
        self.id = filename
        self.backgroundColor = backgroundColor
        Task {
            let im = try await worker.image(name: filename, folder: folder, type: type)
            self.image = im
            
        }
    }
    
}
