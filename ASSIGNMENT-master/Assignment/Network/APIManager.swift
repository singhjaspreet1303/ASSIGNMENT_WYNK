//
//  APIManager.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import Foundation

class APIManager {
    
    static var sharedManager: APIManager = APIManager()
    
    private init() {}
    
    func getData(fromURLObject urlObject:URLObject, completionBlock:@escaping (_ data:Data?, _ error:Error?) -> Void) {
        let req = URLRequest(url: URL(string: urlObject.urlPath)!)
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard let data = data else {
                completionBlock(nil, error)
                return
            }
            completionBlock(data, nil);
        }.resume()
        
    }
    
}
