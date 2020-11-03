//
//  TappableView.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 28.10.2020.
//

import UIKit

class TappableImageView: UIImageView {
    
    typealias Function = (_ gesture: UIGestureRecognizer) -> ()
    var tappedFunction: Function?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    @objc func tapped(gesture: UIGestureRecognizer) {
        if let tappedFunction = tappedFunction {
            tappedFunction(gesture)
        }
    }
    
    private func setupView() {
        let image = UIImage(named: "photo mock.jpg")
        self.image = image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(gesture:)))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
    }
    
}
