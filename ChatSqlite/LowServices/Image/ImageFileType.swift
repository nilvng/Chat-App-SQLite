//
//  ImageFileType.swift
//  ChatSqlite
//
//  Created by LAP11353 on 29/04/2022.
//

import UIKit

enum ImageFileType {
    case original, thumbnail, both, avatar, rounded, video
    func types() -> [ImageFileType] {
        switch self {
        case .both:
            return [.thumbnail, .original]
        case .avatar:
            return [.original, .rounded]
        case .video:
            return [.thumbnail, .original]
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
        let videoExension = ".MP4"
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
