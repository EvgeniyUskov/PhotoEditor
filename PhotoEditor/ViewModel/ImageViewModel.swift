//
//  EditedState.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 27.10.2020.
//

import UIKit
import CoreData

class ImageViewModel {
    var image: UIImage?
    var thumbnail: UIImage?
    var isBusy: Bool = false
    var name: String?
    
    init(image: UIImage, name: String) {
        self.image = image
        self.isBusy = false
        self.name = name
        self.thumbnail = UIImage(data: (image.compress(to: 256)) )!
    }
    
    init(image: UIImage, busy: Bool, name: String) {
        self.image = image
        self.isBusy = busy
        self.name = name
        generateThumbnail(from: image)
    }

    static func fromEditedImage(editedImage: EditedImage, name: String) -> ImageViewModel? {
        guard let image = UIImage.readFromDocumentsFolder(withName: name) else { return nil }
        
        return ImageViewModel(image: image,
                              busy: false,
                              name: name)
    }
    
    func generateThumbnail(from image: UIImage ) {
        self.thumbnail = UIImage(data: (image.compress(to: 256)) )!
    }
}
