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
    
    var editedImages = [EditedImage]()
    var library = [ImageViewModel]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData(completion: {
            [unowned self] in
            self.initLibrary()
        })
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
    
    func loadData(completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            [unowned self] in
            let request : NSFetchRequest<EditedImage> = EditedImage.fetchRequest()
            do {
                self.editedImages = try self.context.fetch(request)
                completion()
            } catch {
                print("Error fetching data from context: \(error)")
            }
        }
    }
    
    func initLibrary() {
        var viewModels = [ImageViewModel]()
        DispatchQueue.main.async {
            [unowned self] in
            if self.editedImages.isEmpty {
                loadingScreenView.stopAnimatingActivityIndicator()
                self.performSegue(withIdentifier: Constants.Segues.segueToMainScreen, sender: self)
            }
            else {
                for editedImage in editedImages {
                    if let name = editedImage.name {
                        if let image = UIImage.readFromDocumentsFolder(withName: name) {
                            viewModels.append(
                                ImageViewModel(
                                    image: image,
                                    name: editedImage.name!
                                )
                            )
                        }
                    }
                }
                library = viewModels
                loadingScreenView.stopAnimatingActivityIndicator()
                performSegue(withIdentifier: Constants.Segues.segueToMainScreen, sender: self)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.segueToMainScreen {
            let viewController = segue.destination as! ViewController
            viewController.viewModel = UICollectionViewViewModel(editedImages: self.editedImages, imageViewModels: self.library)
        }
        //        viewLocal.activityIndicatorView.stopAnimating()
    }
}
