//
//  ImageDAO.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 16.11.2020.
//

import Foundation
import UIKit

protocol ImageStorage {
    
    func loadImage(withName name: String) -> UIImage?
    func loadImages(imageInfos: [ImageInfo]) -> [ImageViewModel]
    func saveImage(fromImageViewModel imageViewModel: ImageViewModel)
    func deleteImage(withName name: String)
    
}
