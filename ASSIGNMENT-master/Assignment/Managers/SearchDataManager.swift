//
//  SearchDataManager.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import Foundation

struct SearchResult {
    
    var currentPage: Int
    var totalRecords: Int = 0
    var totalHitsSoFar: Int = 0 {
        didSet {
            if totalHitsSoFar >= totalRecords {
                noMoreResultsForCurrentQuery = true
            }
        }
    }
    let searchQuery: String
    var noMoreResultsForCurrentQuery: Bool = false
    
    init(searchQuery: String, currentPage: Int = 1) {
        self.currentPage = currentPage
        self.searchQuery = searchQuery
    }
    
}

class SearchDataManager {
    
    static var sharedManager: SearchDataManager = SearchDataManager()
    var searchResult: SearchResult?
    
    fileprivate func getUrlObjectForSearchQuery(query: String, withPageNumber pageNumber: Int = 1) -> URLObject? {
        if let searchResult = searchResult {
            if (searchResult.noMoreResultsForCurrentQuery == true) {
                return nil;
            }
        }
        
        let queryToSearch = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var searchQueryUrl: String = "https://pixabay.com/api/?key=17133401-71c90047e1c669d8379df4503&q=" + queryToSearch + "&image_type=photo"
        
        if (pageNumber > 1) {
            searchQueryUrl = searchQueryUrl + "&page=" + "\(pageNumber)"
            searchResult?.currentPage = pageNumber
        }
        
        let searchUrlObject = URLObject(urlPath: searchQueryUrl)
        return searchUrlObject
    }
    
    fileprivate func getDataForUrlObjectFromQuery(urlObject: URLObject?, completionBlock: @escaping (_ data:[ImageCollectionViewCellModel]?, _ error:Error?) -> Void) {
        if let urlObject = urlObject {
            DataManager.getData(fromURLObject: urlObject, ofType: SearchResultModel.self) { [weak self] (data, error) in
                
                var imagesArray: [ImageCollectionViewCellModel] = []

                if let searchResultModel: SearchResultModel = data {
                    
                    if let totalHits = searchResultModel.totalHits {
                        self?.searchResult?.totalRecords = totalHits
                    }
                                        
                    if let photosArray: [ImageModel] = searchResultModel.photosArray {
                        for imageModel in photosArray {
                            imagesArray.append(ImageCollectionViewCellModel(withImageModel: imageModel))
                        }
                    }
                }
                
                if (imagesArray.count > 0) {
                    if let totalHitsSoFar = self?.searchResult?.totalHitsSoFar {
                        self?.searchResult?.totalHitsSoFar = totalHitsSoFar + imagesArray.count
                    }
                    completionBlock(imagesArray, nil)
                } else {
                    if let searchResult = self?.searchResult, searchResult.currentPage > 1 {
                        self?.searchResult?.currentPage = searchResult.currentPage - 1
                    }
                    if let _ = error {
                        completionBlock(nil, error)
                    } else {
                        completionBlock(imagesArray, nil)
                    }
                }
                
            }
        } else {
            if let searchResult = searchResult, searchResult.currentPage > 1 {
                self.searchResult?.currentPage = searchResult.currentPage - 1
            }
        }
        
    }
    
    func getDataForQuery(query: String, completionBlock: @escaping (_ data:[ImageCollectionViewCellModel]?, _ error:Error?) -> Void) {
        searchResult = SearchResult(searchQuery: query)
        getDataForUrlObjectFromQuery(urlObject: getUrlObjectForSearchQuery(query: query), completionBlock: completionBlock)
    }
    
    func getDataForNextPage(completionBlock: @escaping (_ data:[ImageCollectionViewCellModel]?, _ error:Error?) -> Void) {
        if let searchResult = searchResult {
            getDataForUrlObjectFromQuery(urlObject: getUrlObjectForSearchQuery(query: searchResult.searchQuery, withPageNumber: searchResult.currentPage + 1), completionBlock: completionBlock)
        }
    }
}
