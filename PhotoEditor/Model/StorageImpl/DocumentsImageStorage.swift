//
//  DocumentsDAOImpl.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 16.11.2020.
//

import Foundation
import UIKit

class DocumentsImageStorage: ImageStorage {
    
    static let shared = DocumentsImageStorage()
    private init() {}
    
    func loadImage(withName name: String) -> UIImage? {
        return readFromDocumentsFolder(withName: name)
    }
    
    func loadImages(imageInfos: [ImageInfo]) -> [ImageViewModel] {
        var viewModels = [ImageViewModel]()
        
        for imageInfo in imageInfos {
            if let name = imageInfo.name {
                if let image = readFromDocumentsFolder(withName: name) {
                    viewModels.append(
                        ImageViewModel(
                            image: image,
                            name: imageInfo.name!
                        )
                    )
                }
            }
        }
        
        return viewModels
    }
 
    func saveImage(fromImageViewModel imageViewModel: ImageViewModel)  {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let name = imageViewModel.name else { return }
        guard let image = imageViewModel.image else { return }
        
        let url = documents.appendingPathComponent(name)
        if let data = image.jpegData(compressionQuality: 1.0) { //TODO: разобратся с качеством
            do {
                try data.write(to: url)
            } catch {
                print("Error: Unable to Write Image Data to Disk")
            }
        }
    }
    
    func deleteImage(withName name: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileManager = FileManager.default
        let imagePath = documents.appendingPathComponent(name).path
        
        if fileManager.fileExists(atPath: imagePath) {
            try! fileManager.removeItem(atPath: imagePath)
        }
    }
    
    func writeToDocumentsFolder(fromImageViewModel imageViewModel: ImageViewModel)  {
          let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
          guard let name = imageViewModel.name else { return }
          guard let image = imageViewModel.image else { return }
  
          let url = documents.appendingPathComponent(name)
          if let data = image.jpegData(compressionQuality: 1.0) { //TODO: разобратся с качеством
              do {
                  try data.write(to: url)
              } catch {
                  print("Error: Unable to Write Image Data to Disk")
              }
          }
      }
  
      func readFromDocumentsFolder(withName name: String) -> UIImage? {
          let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
          let fileManager = FileManager.default
          let imagePath = documents.appendingPathComponent(name).path
          if fileManager.fileExists(atPath: imagePath){
              return UIImage(contentsOfFile: imagePath)
          } else {
              print("Error: No such Image with name: \(name)")
              return nil
          }
      }
      
      static func deleteFromDocumentsFolder(withName name: String) {
          let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
          let fileManager = FileManager.default
          let imagePath = documents.appendingPathComponent(name).path
  
          if fileManager.fileExists(atPath: imagePath) {
              try! fileManager.removeItem(atPath: imagePath)
          }
      }
      
}
