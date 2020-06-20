//
//  ImageCollectionViewCell.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var imageViewForSearchResult: UIImageView!

    // MARK: Properties
    var indexPathFromParent: IndexPath!
    
    // MARK: Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    override func prepareForReuse() {
        setUp()
    }
    
    // MARK: Helper Methods
    func setUp() {
        self.imageViewForSearchResult.image = nil
    }
    
    func loadImageForModel(imageModel: ImageCollectionViewCellModel, indexPath: IndexPath) {
        let url = imageModel.previewURL ?? ""
        indexPathFromParent = indexPath
        self.imageViewForSearchResult.downloadImageFromServerWithURLString(url) { [weak self, indexPath] (image, error) in
            if (image != nil && indexPath.row == self?.indexPathFromParent.row) {
                self?.imageViewForSearchResult.image = image
            }
        }
    }
    
}
