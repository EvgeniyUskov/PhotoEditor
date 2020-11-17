//
//  LoadingViewController.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 01.11.2020.
//

import UIKit
import CoreData

class LoadingViewController: UIViewController {
    private let loadingScreenView: LoadingScreenView = {
        let view = LoadingScreenView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
        view.backgroundImageView.contentMode = .scaleAspectFill
        view.accessibilityIdentifier="[LoadingSCRView]"
        view.accessibilityLabel = "[LoadingSCRView]"
        return view
    }()
    
    var imageInfos = [ImageInfo]()
    var library = [ImageViewModel]()
    
    let imageInfoDAO = CoreDataDAOImpl.shared
    let imageDAO = DocumentsDAOImpl.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    func setupView() {
        view.addSubview(loadingScreenView)
        
        loadingScreenView.accessibilityIdentifier = "[VCLoadingScreenView]"
        loadingScreenView.accessibilityLabel = "[VCLoadingScreenView]"
        
        let VCConstr1 = loadingScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        VCConstr1.identifier = "VCConstr1"
        VCConstr1.accessibilityLabel = "VCConstr1"
        let VCConstr2 = loadingScreenView.topAnchor.constraint(equalTo: view.topAnchor)
        VCConstr2.identifier = "VCConstr2"
        VCConstr2.accessibilityLabel = "VCConstr2"
        let VCConstr3 = view.trailingAnchor.constraint(equalTo: loadingScreenView .trailingAnchor)
        VCConstr3.identifier = "VCConstr3"
        VCConstr3.accessibilityLabel = "VCConstr3"
        let VCConstr4 = view.bottomAnchor.constraint(equalTo: loadingScreenView.bottomAnchor)
        VCConstr4.identifier = "VCConstr4"
        VCConstr4.accessibilityLabel = "VCConstr4"
        
        NSLayoutConstraint.activate( [
            VCConstr1,
            VCConstr2,
            VCConstr3,
            VCConstr4
        ])
        loadingScreenView.startAnimatingActivityIndicator()
    }
    
    func loadData() {
        DispatchQueue.global().async {
            [unowned self] in
            imageInfoDAO.loadImageInfos(completion: {
                [unowned self]
                imageInfos in
                self.initLibrary(imageInfos: imageInfos)
            })
        }
    }
    
    func initLibrary(imageInfos: [ImageInfo]) {
        
        DispatchQueue.main.async {
            [unowned self] in
            if imageInfos.isEmpty {
                loadingScreenView.stopAnimatingActivityIndicator()
                self.performSegue(withIdentifier: Constants.Segues.segueToMainScreen, sender: self)
            }
            else {
                self.imageInfos = imageInfos
                library = imageDAO.loadImages(imageInfos: imageInfos)
                
                loadingScreenView.stopAnimatingActivityIndicator()
                performSegue(withIdentifier: Constants.Segues.segueToMainScreen, sender: self)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.segueToMainScreen {
            let viewController = segue.destination as! ViewController
            viewController.viewModel = UICollectionViewViewModel(imageInfos: self.imageInfos, imageViewModels: self.library)
        }
    }
}
