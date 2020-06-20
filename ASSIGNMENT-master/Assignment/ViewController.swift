//
//  ViewController.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var suggestionTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var suggestionsTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    var currentSearchQuery = ""
    var imagesResults: [ImageCollectionViewCellModel] = []
    var suggestions: [String] = []
    let cellHeight: CGFloat = 44.0
    var persistenceManager: PersistenceManager = PersistenceManager()
    var selectedIndex: Int = 0

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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(hideAll))
//        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.suggestionTableView.register(SuggestionTableViewCell.self, forCellReuseIdentifier: "SuggestionTableViewCell")
        self.suggestionTableView.isScrollEnabled = false
        self.updateSuggestionTableViewFrame(isHidden: true)
        
        if let lastSearchedResults: [String] = self.persistenceManager.getData() {
            suggestions = lastSearchedResults
        }
    }
    
    fileprivate func updateSuggestionTableViewFrame(isHidden hidden: Bool) {
        if (hidden) {
            self.suggestionsTableViewHeightConstraint.constant = 0
        } else {
            self.suggestionsTableViewHeightConstraint.constant = CGFloat(suggestions.count) * cellHeight
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.suggestionTableView.reloadData()
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
        
        SearchDataManager.sharedManager.getDataForQuery(query: query) {[weak self, query] (imagesArray, error) in
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
                        self?.appendLastSuggestion(query: query)
                        self?.imagesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    fileprivate func appendLastSuggestion(query: String) {
        if let index = self.suggestions.firstIndex(of: query) {
            self.suggestions.remove(at: index)
        }
        self.suggestions.insert(query, at: 0)
        if (self.suggestions.count > 10) {
            self.suggestions.removeLast()
        }
        persistenceManager.persist(results: suggestions)
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
    
    func hideSuggestionsTableView() {
        self.updateSuggestionTableViewFrame(isHidden: true)
    }
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: @objc methods
    @objc func hideAll() {
        hideSuggestionsTableView()
        hideKeyboard()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let allowedHeight = self.view.frame.size.height - (self.suggestionTableView.frame.origin.y + keyboardHeight + 10)
            if (self.suggestionsTableViewHeightConstraint.constant > 0
                && self.suggestionsTableViewHeightConstraint.constant > allowedHeight) {
                self.suggestionsTableViewHeightConstraint.constant = allowedHeight
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.suggestionTableView.isScrollEnabled = true
            } else {
                self.suggestionTableView.isScrollEnabled = false
            }
        }
    }
}

extension ViewController { // NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailImageCollectionViewController: DetailImageCollectionViewController = segue.destination as? DetailImageCollectionViewController {
            detailImageCollectionViewController.imagesArray = imagesResults
            detailImageCollectionViewController.selectedIndex = selectedIndex
        }
    }
}

extension ViewController: UISearchBarDelegate {
    // MARK: UISearchBarDelegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideAll()
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.updateSuggestionTableViewFrame(isHidden: false)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        if (scrollView == self.suggestionTableView) {
//            hideKeyboard()
        } else {
            hideAll()
        }
    }
    
    // MARK: UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (imagesResults.count > 0 && indexPath.row >= imagesResults.count - 10) {
            fetchResultsForNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "someIdentifier", sender: self)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SuggestionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SuggestionTableViewCell") as? SuggestionTableViewCell else {
            return UITableViewCell()
        }
        cell.update(withTitle: suggestions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideAll()
        fetchAndShowSearchResults(forQuery: suggestions[indexPath.row])
    }
}


