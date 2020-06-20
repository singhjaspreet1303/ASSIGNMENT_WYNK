//
//  SearchResultModel.swift
//  Assignment_WYNK
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import Foundation

struct SearchResultModel: Decodable {
    let total: Int?
    let totalHits: Int?
    let photosArray: [ImageModel]?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case totalHits
        case photosArray = "hits"
    }
    
}
