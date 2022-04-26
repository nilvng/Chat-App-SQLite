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
    
    func load(filename: String, folder: String?=nil, type: ImageFileType){
        self.id = filename
        self.backgroundColor = .trueLightGray
        Task {
            let im = try await worker.image(name: filename, folder: folder, type: type)
            self.image = im
            
        }
    }
    
    func load(index: Int, message: MessageDomain, type: ImageFileType){
        self.id = String(index)
        self.backgroundColor = .trueLightGray
        Task {
            let im = try await worker.image(index: index, of: message, type: type)
            if self.id == String(index) {
                self.image = im
            }
        }
    }
}
