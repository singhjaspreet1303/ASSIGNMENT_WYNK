//
//  URLObject.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import Foundation

enum RequestType {
    case get, post
}

class URLObject {
    
    var url:URL?
    var requestType:RequestType = .get
    var urlPath:String
    
    init(urlPath:String) {
        self.urlPath = urlPath
    }
    
    func checkSanity() -> NSError? {
        self.url = URL(string: urlPath)
        if url == nil {
            return NSError(domain: "Bad URL", code:400 )
        }
        return nil
    }
}
