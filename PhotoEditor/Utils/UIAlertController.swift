//
//  UIAlertController.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 03.11.2020.
//

import Foundation
import UIKit

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
