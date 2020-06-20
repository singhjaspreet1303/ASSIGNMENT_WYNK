//
//  ImageCollectionViewCellModel.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import Foundation

struct ImageCollectionViewCellModel {
    
    let previewURL: String?
    let largeImageURL: String?

    init(withImageModel imageModel: ImageModel) {
        self.previewURL = imageModel.previewURL
        self.largeImageURL = imageModel.largeImageURL
    }

}
