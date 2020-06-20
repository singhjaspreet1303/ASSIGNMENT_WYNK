//
//  ImageDownloader.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

fileprivate let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {

    func downloadImageFromServerWithURLString(_ URLString: String, completionBlock:@escaping (_ image:UIImage?, _ error:Error?) -> Void) {
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            completionBlock(cachedImage, nil)
            return
        }

        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(error?.localizedDescription ?? "")")
                    DispatchQueue.main.async {
                        completionBlock(nil, error)
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            completionBlock(downloadedImage, nil)
                        }
                    }
                }
            }).resume()
        }
    }
}
