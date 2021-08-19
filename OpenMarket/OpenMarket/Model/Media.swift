//
//  Media.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/18.
//

import UIKit

struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.fileName = "photo\(arc4random()).jpeg"
        
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}
