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
    var isBusy: Bool = false
    var name: String?
    
    init(image: UIImage, name: String) {
        self.image = image
        self.isBusy = false
        self.name = name
    }
    
    init(image: UIImage, busy: Bool, name: String) {
        self.image = image
        self.isBusy = busy
        self.name = name
    }

    static func fromEditedImage(editedImage: EditedImage, name: String) -> ImageViewModel? {
        guard let image = UIImage.readFromDocumentsFolder(withName: name) else { return nil }
        
        return ImageViewModel(image: image,
                              busy: false,
                              name: name)
    }
}
