//
//  ImageDAO.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 16.11.2020.
//

import Foundation
import UIKit

class ImageDAO {
    
    static let shared = ImageDAO()
    private init() {}
    
    func loadImageFromDocuments(withName name: String) -> UIImage? {
        return UIImage.readFromDocumentsFolder(withName: name)
    }
    
    func loadImagesFromDocuments(imageInfos: [ImageInfo]) -> [ImageViewModel] {
        var viewModels = [ImageViewModel]()
        
        for imageInfo in imageInfos {
            if let name = imageInfo.name {
                if let image = UIImage.readFromDocumentsFolder(withName: name) {
                    viewModels.append(
                        ImageViewModel(
                            image: image,
                            name: imageInfo.name!
                        )
                    )
                }
            }
        }
        
        return viewModels
    }
    
}
