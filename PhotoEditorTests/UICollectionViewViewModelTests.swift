//
//  PhotoEditorTests.swift
//  PhotoEditorTests
//
//  Created by Evgeniy Uskov on 27.10.2020.
//

import XCTest
@testable import PhotoEditor

class UICollectionViewViewModelTests: XCTestCase {
    let fileName = "testImage"
    let testImg = UIImage(named: "testImage")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var viewModel: UICollectionViewViewModel?
    
    override func setUpWithError() throws {
        let edImg01 = EditedImage(context: context)
        edImg01.name = fileName
        let imgViewModel01 = ImageViewModel(image: testImg!, name: fileName)
        
        viewModel = UICollectionViewViewModel(editedImages: [edImg01], imageViewModels: [imgViewModel01])
    }
    override func tearDownWithError() throws {
        guard let viewModel = viewModel else {return}
        for editedImage in viewModel.editedImages! {
            context.delete(editedImage)
        }
        viewModel.editedImages?.removeAll()
        viewModel.saveData()
    }
    
    func testInvertColorsInternalShouldReturnImage() {
        let image = viewModel?.invertColorsInternal(image: testImg!)
        XCTAssertNotNil(image, "Error while invertColorsInternal: no image")
    }
    
    func testLeftToRightInternal() {
        let image = viewModel?.leftToRightInternal(image: testImg!)
        XCTAssertNotNil(image, "Error while testLeftToRightInternal: no image")
    }
    
    func testAddImageToLibrary() {
        let expectedCount = 2
        let expectation = self.expectation(description: #function)
        guard let viewModel = viewModel else { return }
        viewModel.addImageToLibraryInternal(image: testImg!, busy: false, completion: {
            [unowned viewModel]
            (imageViewModel: ImageViewModel) in
            
            let editedImage = EditedImage(context: viewModel.context)
            UIImage.writeToDocumentsFolder(fromImageViewModel: imageViewModel)
            editedImage.name = imageViewModel.name
            viewModel.editedImages?.append(editedImage)
            viewModel.saveData()
            
            expectation.fulfill()
        })
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(viewModel.library?.count, viewModel.editedImages?.count, "Error: quantity of elements in library and editedImages is not equal")
        XCTAssertEqual(viewModel.library?.count, expectedCount, "Error: quantity of elements in library not equals \(expectedCount)")
        XCTAssertEqual(viewModel.editedImages?.count, expectedCount, "Error: quantity of elements in editedImages not equals \(expectedCount)")
    }
    
    func testEditImageInLibraryInternal() {
        let position = 1
        let expectedCount = 2
        let expectationAdd = self.expectation(description: #function)
        
        guard let viewModel = viewModel else { return }
        viewModel.addImageToLibraryInternal(image: testImg!, busy: true, completion: {
            [unowned viewModel]
            (imageViewModel: ImageViewModel) in
            
            let editedImage = EditedImage(context: viewModel.context)
            UIImage.writeToDocumentsFolder(fromImageViewModel: imageViewModel)
            editedImage.name = imageViewModel.name
            viewModel.editedImages?.append(editedImage)
            viewModel.saveData()
            
            expectationAdd.fulfill()
        })
        waitForExpectations(timeout: 10)
        
        let expectationEdit = self.expectation(description: #function)
        viewModel.editImageInLibraryInternal(image: testImg!, atRow: position, completion: {
            (imageViewModel) in
            let editedImage = viewModel.editedImages![position]
            UIImage.writeToDocumentsFolder(fromImageViewModel: imageViewModel)
            editedImage.name = imageViewModel.name
            
            expectationEdit.fulfill()
            
        })
        waitForExpectations(timeout: 30)
        XCTAssertEqual(viewModel.library?.count, viewModel.editedImages?.count, "Error: quantity of elements in library and editedImages is not equal")
        XCTAssertEqual(viewModel.library?.count, expectedCount, "Error: quantity of elements in library not equals \(expectedCount)")
        XCTAssertEqual(viewModel.editedImages?.count, expectedCount, "Error: quantity of elements in editedImages not equals \(expectedCount)")
    }
    
}
