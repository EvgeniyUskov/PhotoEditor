//
//  PhotoEditorTests.swift
//  PhotoEditorTests
//
//  Created by Evgeniy Uskov on 27.10.2020.
//

import XCTest
@testable import PhotoEditor

class PhotoEditorTests: XCTestCase {
    let fileName = "testImage"
    let testImg = UIImage(named: "testImage")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var imgInf01: ImageInfo?
    var imgViewModel01: ImageViewModel?
    
    override func setUpWithError() throws {
        imgInf01 = ImageInfo(context: context)
        imgInf01!.name = fileName
        imgViewModel01 = ImageViewModel(image: testImg!, name: fileName)
        
    }

    override func tearDownWithError() throws {
        context.delete(imgInf01!)
        imgInf01 = nil
        imgViewModel01 = nil
    }
    
    func testViewModeCreationValid() {
        let testImgLocal = testImg!
        let imageViewModel = ImageViewModel(image: testImgLocal, name: "testImage.jpg")
        
        XCTAssertNotNil(imageViewModel.image!, "Error paramenter: image is nil")
        XCTAssertEqual(imageViewModel.isBusy, false, "Error parameter: isBusy")
    }
    
    func testViewModeCreationWithBusyValid() {
        let testImgLocal = testImg!
        let imageViewModel = ImageViewModel(image: testImgLocal, busy: true, name: "testImage.jpg" )
        
        XCTAssertNotNil(imageViewModel.image!, "Error paramenter: image is nil")
        XCTAssertEqual(imageViewModel.isBusy, true, "Error parameter: isBusy")
    }
    
    func testConvertImageInfoToImageViewModel (){
        let imageInfo = ImageInfo(context: context)
        let imageViewModel = ImageViewModel.fromImageInfo(imageInfo: imageInfo, name: fileName)
        XCTAssertEqual(imageViewModel?.name, imageInfo.name, "Error parameter: name")
    }
    
    func testConvertToCGImage() {
        let ciImage = CIImage(image: testImg!)?.oriented(forExifOrientation: UIImageConverter.imageOrientationToTiffOrientation(value: testImg!.imageOrientation))
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            let newImage = UIImageConverter.convertCIImageToUIImage(inputImage: filter.outputImage!)
            XCTAssertEqual(testImg?.imageOrientation, newImage.imageOrientation)
        }
    }
    
}
