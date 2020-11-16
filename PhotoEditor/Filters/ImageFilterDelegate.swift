//
//  ImageFilterDelegate.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 13.11.2020.
//

import Foundation
import UIKit

protocol ImageFilterDelegate {
    func addImageToLibrary(image: UIImage, busy: Bool)
    func editImageInLibrary(image: UIImage, atRow row: Int)
    func activateProgressView(forRow: Int)
    func slowDown(forRow row: Int?)
    func reloadItem(forRow row: Int, withImage image: UIImage)
}
