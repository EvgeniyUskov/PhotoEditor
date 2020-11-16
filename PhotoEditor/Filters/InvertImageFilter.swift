//
//  InvertImagefilter.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 12.11.2020.
//

import Foundation
import UIKit

struct InvertImageFilter: ImageFilterType {
    
    var delegate: ImageFilterDelegate?
    
    func applyFilter(viewModel: UICollectionViewViewModel, image: UIImage, completion: @escaping (Int, UIImage) -> ()) {
        delegate?.addImageToLibrary(image: image, busy: true)
        let imageRow =  viewModel.getImageRow()!
        delegate?.activateProgressView(forRow: imageRow)
        
        DispatchQueue.global().async {
            let newImage: UIImage?
            let ciImage = CIImage(image: image)?.oriented(forExifOrientation: UIImageConverter.imageOrientationToTiffOrientation(value: image.imageOrientation))
            guard let filter = CIFilter(name: "CIColorInvert") else {return}
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            newImage = UIImageConverter.convertCIImageToUIImage(inputImage: filter.outputImage!)

            
            guard let imageLocal = newImage else { return }
            delegate?.slowDown(forRow: imageRow)
            
            DispatchQueue.main.async {
                delegate?.editImageInLibrary(image: imageLocal, atRow: imageRow)
                if let _ = viewModel.library![viewModel.library!.count - 1].name {
                    DispatchQueue.global().async {
                        viewModel.row = nil
                        viewModel.saveData()
                    }
                    completion(imageRow, imageLocal)
                }
            }
            
        }
        
    }
    
}
