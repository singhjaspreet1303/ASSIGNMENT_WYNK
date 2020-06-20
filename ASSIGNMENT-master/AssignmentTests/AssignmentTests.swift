//
//  AssignmentTests.swift
//  AssignmentTests
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import XCTest
@testable import Assignment

class AssignmentTests: XCTestCase {
    
    var viewController:ViewController!
    var sut: URLSession!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow!.rootViewController = viewController
        XCTAssertNotNil(viewController.view)
        sut = URLSession(configuration: .default)
    }
    
    func testValidCallToiTunesGetsHTTPStatusCode200() {
        let urlObject = URLObject.init(urlPath: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&%20format=json&nojsoncallback=1&safe_search=1&text=Google")
        
        DataManager.getData(fromURLObject: urlObject, ofType: SearchResultModel.self) { (data, error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (data)?.status {
                if statusCode == "200" {
                    XCTAssertEqual(statusCode, "200")
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            } else {
                XCTFail("no response")
            }
            
        }
    }
    
}
