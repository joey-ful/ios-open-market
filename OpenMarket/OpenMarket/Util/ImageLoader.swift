//
//  ImageLoader.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/19.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    
    func loadImage(from imagePath: URL, at cell: ItemCell, completionHandler: @escaping (UIImage) -> ()) {
        
        cell.thumbnailImageView.image = UIImage(systemName: "photo")
        URLSession.shared.dataTask(with: imagePath) { (data, response, error) in
            guard error == nil else { return }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statusCode) else { return }
            guard let data = try? Data(contentsOf: imagePath) else { return }
            guard let imageData = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                completionHandler(imageData)
            }
            
        }.resume()

    }
}
