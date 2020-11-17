//
//  MirrorImageFilter.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 13.11.2020.
//

import Foundation
import UIKit

class MirrorImageFilter: ImageFilterType {
    
    let imageInfoDAO = CoreDataDAOImpl.shared
    
    var delegate: ImageFilterDelegate?
    
    func applyFilter(viewModel: UICollectionViewViewModel, image: UIImage, completion: @escaping (Int, UIImage) -> ()) {
        
        delegate?.addImageToLibrary(image: image, busy: true)
        
        let imageRow =  viewModel.getImageRow()!
        
        delegate?.activateProgressView(forRow: imageRow)
        
        DispatchQueue.global().async {
            [unowned self] in
            let finalImage = viewModel.mirror(image: image)
            self.delegate?.slowDown(forRow: imageRow)
            
            DispatchQueue.main.async {
                self.delegate?.editImageInLibrary(image: finalImage, atRow: imageRow)
                if let _ = viewModel.library![viewModel.library!.count - 1].name {
                    DispatchQueue.global().async {
                        viewModel.row = nil
                        imageInfoDAO.saveImageInfos()
                    }
                    completion(imageRow, finalImage)
                }
            }
        }
    }
}
