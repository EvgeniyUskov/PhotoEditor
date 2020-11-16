//
//  UICollectionViewModel.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 03.11.2020.
//

import Foundation
import UIKit

class UICollectionViewViewModel {
    var imageInfos: [ImageInfo]?
    var library: [ImageViewModel]?
    
    var row: Int?
    var isLastElement: Bool = true
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(imageInfos: [ImageInfo], imageViewModels: [ImageViewModel]) {
        self.imageInfos = imageInfos
        self.library = imageViewModels
    }
    
    func getImageRow() -> Int? {
        var imageRow: Int?
        if let row = row {
            imageRow = row
        } else {
            imageRow = library!.count - 1
        }
        if isLastElement == false {
            imageRow = library!.count - 1
        }
        return imageRow
    }
    
    //    MARK: -ImageFilters
    func mirror(image: UIImage) -> UIImage {
        let size = image.size
        let scale = image.scale
        let cgImage = image.getCGImageWithFixedOrientation()!
        
        let flippedOrientation = UIImage.Orientation.upMirrored
        let flippedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: flippedOrientation)
        // перевернули изображение
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        // исправляем ориентацию в контексте
        context.translateBy(x: 0, y: size.height);
        context.scaleBy(x: 1.0, y: -1.0)
        let cropRect = CGRect(x: flippedImage.size.width/2, y: 0, width: -flippedImage.size.width/2, height: flippedImage.size.height)
        // сделали прямоугольник для кропа - правая часть флипнутого изображения из левой части оригинального изображения
        let theOtherHalf = flippedImage.cgImage!.cropping(to: cropRect)!
        // обрезаем изображение
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        
        var transform: CGAffineTransform = CGAffineTransform(translationX: flippedImage.size.width, y: 0.0)
        transform = transform.scaledBy(x: -1.0, y: 1.0);
        context.concatenate(transform);
        context.draw(theOtherHalf, in: cropRect)
        // рисуем правую часть флипнутого изображения
        
        let image: CGImage = context.makeImage()!
        let finalImage: UIImage = UIImage(cgImage: image)
        return finalImage
    }
    
//    func addImageToLibraryInternal(image: UIImage, busy: Bool, completion: @escaping ((ImageViewModel)) -> () ) {
//        let imageViewModel = ImageViewModel(image: image, busy: busy, name: UIImage.getImageName())
//        library!.append(imageViewModel)
//
//        DispatchQueue.global().async {
//            completion(imageViewModel)
//        }
//    }
    
    func editImageInLibraryInternal(image: UIImage, atRow row: Int, completion: @escaping ((ImageViewModel)) -> () ) {
        library![row].image = image
        library![row].isBusy = false
        DispatchQueue.global().async {
            [unowned self] in
            completion(self.library![row])
        }
    }
    
    func deleteFromLibrary(at row: Int){
        library!.remove(at: row)
    }
    
    func deleteData(at row: Int) {
        context.delete(imageInfos![row])
        imageInfos?.remove(at: row)
        saveData()
    }
    
    func saveData() {
        DispatchQueue.global().async {
            [unowned self] in
            do {
                try self.context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func isLibraryEmpty() -> Bool {
        return library!.isEmpty
    }
    
}
