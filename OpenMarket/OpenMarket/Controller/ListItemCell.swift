//
//  GridItemCollectionViewCell.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/17.
//

import UIKit

class ListItemCell: UICollectionViewListCell, ItemCell {
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
    
    func updateContent(at indexPath: IndexPath, items: [Page.Item]?, collectionView: UICollectionView) {
        
        self.accessories = [.disclosureIndicator()]
        guard let item = items?[indexPath.item] else { return }
        
        /// ImageView
        let imageURLString = item.thumbnails[0]
        guard let imagePath = URL(string: imageURLString) else { return }
        ImageLoader.shared.loadImage(from: imagePath, at: self) { imageData in
            if indexPath == collectionView.indexPath(for: self) {
                self.thumbnailImageView.image = imageData
            }
        }
        
        titleLabel.text = item.title
        stockLabel.text = "잔여수량 \(item.stock.description)"
        priceLabel.text = "\(item.currency) \(item.price.description)"
    }
}
