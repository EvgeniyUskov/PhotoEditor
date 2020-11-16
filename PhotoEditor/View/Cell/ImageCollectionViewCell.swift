//
//  ImageCollectionViewCell.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 27.10.2020.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: ImageViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func setup(imageViewModel: ImageViewModel) {
        self.image = imageViewModel
        self.imageView.image = image?.thumbnail
        progressView.progress = 0.0
        progressView.isHidden = !image!.isBusy
    }
    
    func hideProgresView() {
        if progressView.isHidden == false {
            progressView.isHidden = true
        }
    }
    
    func showProgressView() {
        if progressView.isHidden == true {
            progressView.isHidden = false
        }
    }
    
}
