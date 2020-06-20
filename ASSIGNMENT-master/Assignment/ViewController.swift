//
//  ViewController.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Properties
    var currentSearchQuery = ""
    var imagesResults: [ImageCollectionViewCellModel] = []

    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }

    // MARK: Private methods
    fileprivate func setup() {
        self.searchBar.delegate = self
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func showAlertForEmptyQuery() {
        let alertController = UIAlertController(title: "Image Search", message: "Enter some text", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default) { _ in })
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showAlertForNoResult() {
        let alertController = UIAlertController(title: "Oops!", message: "No result found.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default) { _ in })
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showAlertForError() {
        let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default) { _ in })
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func fetchAndShowSearchResults(forQuery query: String) {
        if (self.imagesResults.count > 0) {
            self.imagesResults.removeAll()
            self.imagesCollectionView.reloadData()
        }
        
        self.imagesCollectionView.isHidden = true;
        self.activityIndicator.isHidden = false;
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        SearchDataManager.sharedManager.getDataForQuery(query: query) {[weak self] (imagesArray, error) in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                self?.imagesCollectionView.isHidden = false;
                self?.activityIndicator.isHidden = true;
                self?.activityIndicator.stopAnimating()
                
                if let _ = error {
                    self?.showAlertForError()
                } else {
                    if (imagesArray == nil || imagesArray?.count == 0) {
                        if (self?.imagesResults.count == 0) {
                            self?.showAlertForNoResult()
                        }
                    } else {
                        self?.imagesResults.append(contentsOf: imagesArray ?? [])
                        self?.imagesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    fileprivate func fetchResultsForNextPage() {
        SearchDataManager.sharedManager.getDataForNextPage {[weak self] (imagesArray, error) in
            if let imagesArray = imagesArray, imagesArray.count > 0 {
                self?.imagesResults.append(contentsOf: imagesArray)
                DispatchQueue.main.async {
                   self?.imagesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func getSizeForItemInCollectionView(forWidth width: CGFloat, layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let noOfCellsInRow = 3
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    // MARK: @objc methods
    @objc func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchBarDelegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideKeyboard()
        if let query = searchBar.text {
            if query.isEmpty {
                showAlertForEmptyQuery()
            } else if currentSearchQuery != query {
                fetchAndShowSearchResults(forQuery: query)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            currentSearchQuery = ""
        }
    }
    
    // MARK: UICollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let imageCell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell {
            imageCell.loadImageForModel(imageModel: imagesResults[indexPath.row], indexPath: indexPath)
            return imageCell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSizeForItemInCollectionView(forWidth:collectionView.frame.size.width, layout: collectionViewLayout)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // MARK: UIScrollViewDelegate Methods
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
    
    // MARK: UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (imagesResults.count > 0 && indexPath.row >= imagesResults.count - 10) {
            fetchResultsForNextPage()
        }
    }
}


