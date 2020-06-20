//
//  PersistenceManager.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class PersistenceManager: NSObject {

    private let fileName = "persistedData"
    
    func persist(results: [String]) {
        UserDefaults.standard.set(results, forKey: fileName)
        UserDefaults.standard.synchronize()
    }
    
    func getData() -> [String]? {
        if let results: [String] = UserDefaults.standard.value(forKey: fileName) as? [String] {
            return results
        }
        return nil
    }
    
}
