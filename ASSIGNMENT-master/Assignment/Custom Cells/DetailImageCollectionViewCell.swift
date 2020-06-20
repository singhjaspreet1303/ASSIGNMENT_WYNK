//
//  DetailImageCollectionViewCell.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class DetailImageCollectionViewCell: UICollectionViewCell {
    // MARK: Outlets
    @IBOutlet weak var imageViewForDetail: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    // MARK: Properties
    var indexPathFromParent: IndexPath!
    
    // MARK: Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Helper Methods
    
    private func updateMinZoomScale(for size: CGSize) {
        let widthScale = size.width / imageViewForDetail.bounds.size.width
        let heightScale = size.height / imageViewForDetail.bounds.size.height
        let minScale = CGFloat(min(widthScale, heightScale))

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale

        scrollView.contentOffset = CGPoint.zero // Will be centered
    }
    
    private func updateConstraints(for size: CGSize) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let yOffset = CGFloat(max(0, (size.height - imageViewForDetail.frame.size.height) / 2))
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let xOffset = CGFloat(max(0, (size.width - imageViewForDetail.frame.size.width) / 2))
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func setImage(image: UIImage?) {
        self.imageViewForDetail.image = image
        updateConstraints(for: UIScreen.main.bounds.size)
        updateMinZoomScale(for: UIScreen.main.bounds.size)
    }
    
    func loadImageForModel(imageModel: ImageCollectionViewCellModel, indexPath: IndexPath) {
        setImage(image: UIImage(named: "placeholder"))
        let url = imageModel.largeImageURL ?? ""
        indexPathFromParent = indexPath
        self.imageViewForDetail.downloadImageFromServerWithURLString(url) { [weak self, indexPath] (image, error) in
            if (image != nil && indexPath.row == self?.indexPathFromParent.row) {
                self?.setImage(image: image)
            }
        }
    }
    
}

extension DetailImageCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewForDetail
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(for: scrollView.bounds.size)
    }
}
