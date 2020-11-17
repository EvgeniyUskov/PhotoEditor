//
//  ImageInfoDAO.swift
//  PhotoEditor
//
//  Created by Evgeniy Uskov on 16.11.2020.
//

import Foundation

protocol ImageInfoDAO {
    
    func loadImageInfos(completion: @escaping ([ImageInfo]) -> () )
    func saveImageInfos()
    
    
}
