//
//  ImageModel.swift
//  Assignment_WYNK
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import Foundation

struct ImageModel: Decodable {
    let imageId: Int?
    let pageURL: String?
    let type: String?
    let tags: String?
    let previewURL: String?
    let previewWidth: Int?
    let previewHeight: Int?
    let webformatURL: String?
    let webformatWidth: Int?
    let webformatHeight: Int?
    let largeImageURL: String?
    let imageWidth: Int?
    let imageHeight: Int?
    let imageSize: Int?
    let views: Int?
    let downloads: Int?
    let favorites: Int?
    let likes: Int?
    let comments: Int?
    let userId: Int?
    let user: String?
    let userImageURL: String?

    private enum CodingKeys: String, CodingKey {
        case imageId = "id"
        case pageURL
        case type
        case tags
        case previewURL
        case previewWidth
        case previewHeight
        case webformatURL
        case webformatWidth
        case webformatHeight
        case largeImageURL
        case imageWidth
        case imageHeight
        case imageSize
        case views
        case downloads
        case favorites
        case likes
        case comments
        case userId = "user_id"
        case user
        case userImageURL
        
    }
    
}
