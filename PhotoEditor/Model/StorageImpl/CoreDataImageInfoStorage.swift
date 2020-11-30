//
//  CoreDataDAOImpl.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 16.11.2020.
//

import Foundation
import UIKit
import CoreData

class CoreDataImageInfoStorage: ImageInfoStorage {
    static let shared = CoreDataImageInfoStorage()
    private init() {}
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadImageInfos(completion: @escaping ([ImageInfo]) -> () ) {
        
        DispatchQueue.global().async {
            var imageInfos = [ImageInfo]()
            let request : NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
            do {
                imageInfos = try self.context.fetch(request)
                completion(imageInfos)
            } catch {
                print("Error fetching data from context: \(error)")
            }
        }
        
    }
    
    func saveImageInfos() {
        
        DispatchQueue.global().async {
            do {
                try self.context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
        
    }
    
    func deleteImageInfo(imageInfo: ImageInfo) {
        context.delete(imageInfo)
    }
    
}
