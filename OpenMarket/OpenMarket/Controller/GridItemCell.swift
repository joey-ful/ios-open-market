//
//  GridCell.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/21.
//

import UIKit

class GridItemCell: UICollectionViewCell, ItemCell {
    var urlString: String?
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
    override func prepareForReuse() {
        thumbnailImageView.image = .none
        titleLabel.text = ""
        priceLabel.text = "잔여수량"
        stockLabel.text = "0"
    }
    
    func updateContent(at indexPath: IndexPath, items: [Page.Item]?) {
        guard let item = items?[indexPath.item] else { return }
        
        /// ImageView
        let imageURLString = item.thumbnails[0]
        guard let imagePath = URL(string: imageURLString) else { return }
        ImageLoader.shared.loadImage(from: imagePath, at: self) { imageData in
            if self.urlString == imageURLString {
                self.thumbnailImageView.image = imageData
            }
        }
        
        titleLabel.text = item.title
        stockLabel.text = "잔여수량 \(item.stock.description)"
        priceLabel.text = "\(item.currency) \(item.price.description)"
    }
}
