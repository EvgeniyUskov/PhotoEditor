//
//  ViewController.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 27.10.2020.
//

import UIKit
import CoreData
import Foundation
class ViewController: UIViewController {
    @IBOutlet private var imageView: TappableImageView!
    
    @IBOutlet weak var loadOrMakePhotoButton: UIButton!
    @IBOutlet weak var invertColorsButton: UIButton!
    @IBOutlet weak var leftToRightButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var viewModel : UICollectionViewViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        setupUI()
        hideAllUIElements()
        
        loadImages(completion: {
            [unowned self] in
            DispatchQueue.main.async {
                guard let viewModel = viewModel else { return }
                if let library = viewModel.library {
                    if (library.isEmpty) {
                        self.showInitialUIElements()
                    } else {
                        self.imageCollectionView.reloadData()
                        let lastIndexPath = IndexPath(item: (library.count - 1), section: 0)
                        self.imageCollectionView.scrollToItem(at: lastIndexPath, at: .bottom , animated: true)
                        if let name = library[library.count-1].name {
                            self.imageView.image = UIImage.readFromDocumentsFolder(withName: name)
                        }
                        self.showUIElements()
                    }
                    self.invertColorsButton.layer.cornerRadius = 10
                    self.leftToRightButton.layer.cornerRadius = 10
                    
                    self.imageView.tappedFunction = {
                        [unowned self]
                        (gesture: UIGestureRecognizer) in
                        if (gesture.view as? UIImageView) != nil {
                            self.showCameraAlert()
                        }
                    }
                    
                }
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }
        })
    }
    
    @IBAction func loadOrMakePhoto(_ sender: Any) {
        showCameraAlert()
    }
    
    @IBAction func invertColors(_ sender: UIButton) {
        guard let viewModel = viewModel else { return }
        invertColorsInternal(row: viewModel.row, completion: {
            [unowned self]
            (newImage, row) in
            DispatchQueue.main.async {
                
                self.editImageInLibrary(image: newImage, atRow: row)
                
                if let name = viewModel.library![viewModel.library!.count - 1].name {
                    self.imageView.image = UIImage.readFromDocumentsFolder(withName: name)
                    viewModel.row = nil
                    viewModel.saveData()
                }
            }
            
        })
    }
    
    @IBAction func leftToRight(_ sender: UIButton) {
        guard let viewModel = viewModel else { return }
        leftToRightInternal(row: viewModel.row, completion: {
            [unowned self]
            (newImage, row) in
            DispatchQueue.main.async {
                guard let viewModel = self.viewModel else { return }
                self.editImageInLibrary(image: newImage, atRow: row)
                if let name = viewModel.library![viewModel.library!.count - 1].name {
                    self.imageView.image = UIImage.readFromDocumentsFolder(withName: name)
                }
                viewModel.row = nil
            }
            
        })
    }
    
    //    MARK: -ImageFilters
    private func invertColorsInternal(row: Int?, completion: @escaping (UIImage, Int) -> ()) {
        guard let image = imageView.image else { return }
        guard let viewModel = viewModel else { return }
        addImageToLibrary(image: image, busy: true)
        let imageRow =  viewModel.getImageRow()!
        
        self.activateProgressView(forRow: imageRow)
        
        DispatchQueue.global().async {
            [unowned self, unowned viewModel, unowned image] in
            let newImage = viewModel.invertColorsInternal(image: image)
            self.slowDown(forRow: imageRow)
            completion(newImage!, imageRow)
        }
    }
    
    private func leftToRightInternal(row: Int?, completion: @escaping (UIImage, Int) -> ()) {
        guard let viewModel = viewModel else { return }
        guard let image = imageView.image else { return }
        
        addImageToLibrary(image: image, busy: true)
        let imageRow =  viewModel.getImageRow()!
        activateProgressView(forRow: imageRow)
        
        DispatchQueue.global().async {
            [unowned self, unowned viewModel, unowned image] in
            let finalImage = viewModel.leftToRightInternal(image: image)
            self.slowDown(forRow: imageRow)
            completion(finalImage, imageRow)
        }
        
    }
    
    //    MARK: -Alert operations
    private func showCameraAlert() {
        let alert = UIAlertController(title: "Сделать снимок или выбрать из фотоальбома.", message: nil, preferredStyle: .actionSheet)
        alert.pruneNegativeWidthConstraints()
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default, handler: {
            [unowned self] _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            
            picker.sourceType = .photoLibrary
            picker.modalPresentationStyle = .fullScreen
            
            present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: {
            [unowned self] _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            } else {
                picker.sourceType = .photoLibrary
                picker.modalPresentationStyle = .fullScreen
            }
            
            present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func showCellAlert(at indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let image: ImageViewModel = viewModel.library![indexPath.row]
        
        if image.isBusy == true{
            let alert = UIAlertController(title: "Изображение обрабатывается...", message: "Подалуйста подождите.", preferredStyle: .alert )
            alert.pruneNegativeWidthConstraints()
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Выберите действие над изображением.", message: nil, preferredStyle: .actionSheet)
            alert.pruneNegativeWidthConstraints()
            alert.addAction(UIAlertAction(title: "Сохранить в галерею", style: .default, handler: {
                [unowned self] _ in
                if let image = image.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveError), nil)
                }
                
            } ))
            alert.addAction(UIAlertAction(title: "Редактировать фото", style: .default, handler: {
                [unowned self] _ in
                imageView.image = UIImage.readFromDocumentsFolder(withName: image.name!)
                viewModel.row = indexPath.row
            } ))
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: {
                [unowned self] _ in
                if let _ = image.image {
                    viewModel.deleteFromLibrary(at: indexPath.row)
                    if viewModel.isLibraryEmpty() {
                        showInitialUIElements()
                    }
                    imageCollectionView.reloadData()
                    DispatchQueue.global().async {
                        if let name = image.name {
                            UIImage.deleteFromDocumentsFolder(withName: name)
                        }
                    }
                    
                    viewModel.deleteData(at: indexPath.row)
                }
            } ))
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Error svaing to Gallery")
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.library!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        guard let viewModel = viewModel else { return UICollectionViewCell()}
        cell.setup(imageViewModel: viewModel.library![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        if indexPath.row != viewModel.library!.count - 1 {
            viewModel.isLastElement = false
        } else {
            viewModel.isLastElement = true
        }
        showCellAlert(at: indexPath)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate methods
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismiss(animated: true)
            return
        }
        
        imageView.image = image
        addImageToLibrary(image: image, busy: false)
        
        loadOrMakePhotoButton.isHidden = true
        dismiss(animated: true)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = imageCollectionView.bounds.width / 3.25
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
}
// MARK: -additional Methods

extension ViewController {
    
    private func setupUI() {
        self.activityIndicatorView.style = .large
        self.activityIndicatorView.color = UIColor(named:  "Activity Indicator Color")
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        imageCollectionView.collectionViewLayout = layout
        imageCollectionView.register(UINib(nibName: Constants.CellProperties.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.CellProperties.cellName)
    }
    
    private func slowDown(forRow row: Int?) {
        DispatchQueue.global().sync {
            [unowned self] in
            let delayedSeconds = Int.random(in: Constants.SlowDownLimits.lowerLimit ... Constants.SlowDownLimits.upperLimit)
            var secondsPassed = 0
            
            weak var timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                [unowned self]
                timer in
                secondsPassed += 1
                let progress: Float = Float(secondsPassed) / Float(delayedSeconds)
                self.updateProgress(progress: progress, forRow: row)
                if(secondsPassed == delayedSeconds){
                    timer.invalidate()
                }
            }
            RunLoop.current.add(timer!, forMode: .default )
            RunLoop.current.run()
        }
    }
    
    private func updateProgress(progress: Float, forRow row: Int?) {
        if let row = row {
            DispatchQueue.main.async {
                [unowned self] in
                let indexPath = IndexPath(item: (row), section: 0)
                let cell = self.imageCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
                cell?.progressView.setProgress(progress, animated: true)
                if(progress == 1.0) {
                    cell?.hideProgresView()
                }
            }
        }
    }
    
    private func addImageToLibrary(image: UIImage, busy: Bool) {
        guard let viewModel = viewModel else { return }
        if loadOrMakePhotoButton.isHidden == false {
            showUIElements()
        }
        viewModel.addImageToLibraryInternal(image: image, busy: busy, completion: {
            [unowned viewModel]
            (imageViewModel: ImageViewModel) in
            
            let editedImage = EditedImage(context: viewModel.context)
            UIImage.writeToDocumentsFolder(fromImageViewModel: imageViewModel)
            editedImage.name = imageViewModel.name
            viewModel.editedImages?.append(editedImage)
            viewModel.saveData()
        })

        imageCollectionView.reloadData()
        let lastIndexPath = IndexPath(item: (viewModel.library!.count - 1), section: 0)
        imageCollectionView.scrollToItem(at: lastIndexPath, at: .bottom , animated: true)
    }
    
    private func editImageInLibrary(image: UIImage, atRow row: Int) {
        guard let viewModel = viewModel else { return }
        viewModel.editImageInLibraryInternal(image: image, atRow: row, completion: {
            (imageViewModel) in
            let editedImage = viewModel.editedImages![row]
            UIImage.writeToDocumentsFolder(fromImageViewModel: imageViewModel)
            editedImage.name = imageViewModel.name
        })
        let indexPath = IndexPath(item: (row), section: 0)
        imageCollectionView.reloadItems(at: [indexPath])
    }
    
    private func showInitialUIElements() {
        imageView.isHidden = true
        imageCollectionView.isHidden = true
        invertColorsButton.isHidden = true
        leftToRightButton.isHidden = true
        
        loadOrMakePhotoButton.isHidden = false
    }
    
    private func hideAllUIElements() {
        imageView.isHidden = true
        imageCollectionView.isHidden = true
        invertColorsButton.isHidden = true
        leftToRightButton.isHidden = true
        loadOrMakePhotoButton.isHidden = true
    }
    
    private func showUIElements() {
        imageView.isHidden = false
        imageCollectionView.isHidden = false
        invertColorsButton.isHidden = false
        leftToRightButton.isHidden = false
        
        loadOrMakePhotoButton.isHidden = true
    }
    
    private func activateProgressView(forRow row: Int) {
        let indexPath = IndexPath(item: (row), section: 0)
        let cell = self.imageCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        if cell != nil {
            
        }
        cell?.showProgressView()
    }
    
    private func loadImages(completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            [unowned self] in
            guard let viewModel = self.viewModel else {return}
            let request : NSFetchRequest<EditedImage> = EditedImage.fetchRequest()
            do {
                viewModel.editedImages = try viewModel.context.fetch(request)
                completion()
            } catch {
                print("Error fetching data from context: \(error)")
            }
        }
    }
}
