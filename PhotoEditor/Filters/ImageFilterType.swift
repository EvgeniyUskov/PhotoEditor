//
//  ImageFilterType.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 12.11.2020.
//

import Foundation
import UIKit

protocol ImageFilterType {
    func applyFilter(viewModel: UICollectionViewViewModel, image: UIImage, completion: @escaping (Int, UIImage) -> ())
}
