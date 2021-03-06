//
//  UIImage.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 29.10.2020.
//

import UIKit

extension UIImage {
    
    func imageOrientationToTiffOrientation(value: UIImage.Orientation) -> Int32 {
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
    
    func getCGImageWithFixedOrientation() -> CGImage? {
        guard let cgImage = cgImage else { return nil }
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
        default:
            break
        }
        
        switch imageOrientation {
        
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            
            ctx.concatenate(transform)
            
            switch imageOrientation {
            
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            if let finalImage = ctx.makeImage() {
                return finalImage
            }
        }
        
        return nil
    }
    
}

extension UIImage {
    func resized() -> UIImage? {
        let windowLocal = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        guard let window = windowLocal else {print("Error: no UIWindow"); return nil}
        let dimension = ((window.bounds.width) - 40) / 3.05

        let canvas = CGSize(width: dimension, height: dimension)
        let format = imageRendererFormat
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    static func getDocumentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func getImageUrlString(name: String) -> String {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return String(describing: documents.appendingPathComponent(name))
    }
    
    static let defaults = UserDefaults.standard
    
    static var counter: Int {
        get {
            defaults.integer(forKey: Constants.UserDefaultsProperties.imageCounter)
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaultsProperties.imageCounter)
        }
    }
    
    static func getImageName() -> String {
        counter = counter + 1
        return "IMG_\(String(format: "%04d", counter)).jpg"
    }
    
}
