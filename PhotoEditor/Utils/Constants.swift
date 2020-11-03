//
//  Constants.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 02.11.2020.
//

import Foundation

enum Constants {
    enum CellProperties {
        static let cellName = "imageCell"
        static let cellNibName = "ImageCollectionViewCell"
    }
    
    enum UserDefaultsProperties {
        static let imageCounter = "Image Counter"
    }
    enum Segues {
        static let segueToMainScreen = "goToMainScreen"
    }
    enum SlowDownLimits {
        static let lowerLimit = 5
        static let upperLimit = 30
        static let upperLimitForTest = 6
    }
}
