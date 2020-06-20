//
//  DataManager.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class DataManager {
    
    class func getData(fromURLObject urlObject:URLObject, ofType type: SearchResultModel.Type, completionBlock:@escaping (_ data:SearchResultModel?, _ error:Error?) -> Void) {
        
        DispatchQueue.global().sync {
            DispatchQueue.main.async {
                guard UIApplication.shared.applicationState != .background else {
                    print("Data fetch failed for : \(urlObject.urlPath)")
                    completionBlock(nil, NSError(domain:"Application in background.", code: -1040))
                    return
                }
            }
        }
        
        if let error = urlObject.checkSanity() {
            completionBlock(nil, error)
        } else if let _ = urlObject.url {
            APIManager.sharedManager.getData(fromURLObject: urlObject) { (data, error) in
                if let responseJson = data {
                    do {
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(SearchResultModel.self, from: responseJson)
                        completionBlock(model, nil)
                    } catch let exceptionError {
                        completionBlock(nil, exceptionError)
                    }
                } else {
                    let finalError = NSError(domain:"No response from Server." , code:400)
                    completionBlock(nil, error ?? finalError)
                }
            }
        }
        
    }
    
}
