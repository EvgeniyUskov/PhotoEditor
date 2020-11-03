//
//  Convertor.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 02.11.2020.
//

import Foundation
import UIKit

struct UIImageConverter {
    static func convertCIImageToUIImage(inputImage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(inputImage, from: inputImage.extent)
        return UIImage(cgImage: cgImage!)
    }
    
    static func imageOrientationToTiffOrientation(value: UIImage.Orientation) -> Int32 {
        switch (value)
        {
        case .up:
            return 1
        case .down:
            return 3
        case .left:
            return 8
        case .right:
            return 6
        case .upMirrored:
            return 2
        case .downMirrored:
            return 4
        case .leftMirrored:
            return 5
        case .rightMirrored:
            return 7
        default:
            return 1
        }
    }
}
