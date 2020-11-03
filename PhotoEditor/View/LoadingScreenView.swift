//
//  LoadingScreenView.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 02.11.2020.
//

import UIKit

@IBDesignable
class LoadingScreenView: UIView {
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityLabel = "[imageView]"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "back")
        return imageView
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.color = UIColor(named: "Activity Indicator Color")
        activityView.accessibilityLabel = "[activityView]"
        return UIActivityIndicatorView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        accessibilityIdentifier = "[LoadingScreenView]"
        backgroundImageView.accessibilityIdentifier = "[backgroundImageView]"
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = UIColor(named: "Activity Indicator Color")
        addSubview(backgroundImageView)
        addSubview(activityIndicatorView)
        
        let constrScreenView1 = backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor)
        constrScreenView1.identifier = "[constrScreenView1]"
        constrScreenView1.accessibilityLabel = "[constrScreenView1]"
        let constrScreenView2 = trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor)
        constrScreenView2.identifier = "[constrScreenView2]"
        constrScreenView1.accessibilityLabel = "[constrScreenView2]"
        let constrScreenView3 = backgroundImageView.topAnchor.constraint(equalTo: topAnchor)
        constrScreenView3.identifier = "[constrScreenView3]"
        constrScreenView1.accessibilityLabel = "[constrScreenView3]"
        let constrScreenView4 = bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor)
        constrScreenView4.identifier = "[constrScreenView4]"
        constrScreenView1.accessibilityLabel = "[constrScreenView4]"
        
        let actViewCenterX = activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
        actViewCenterX.identifier = "[actViewCenterX]"
        actViewCenterX.accessibilityLabel = "[actViewCenterX]"
        let actViewCenterY = activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        actViewCenterY.identifier = "[actViewCenterY]"
        actViewCenterY.accessibilityLabel = "[actViewCenterY]"
        
        NSLayoutConstraint.activate([
            constrScreenView1,
            constrScreenView2,
            constrScreenView3,
            constrScreenView4,
            
            actViewCenterX,
            actViewCenterY,
        ])
    }
    
    func startAnimatingActivityIndicator() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }
    
    func stopAnimatingActivityIndicator() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
}
