//
//  ItemCell.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/21.
//

import UIKit

protocol ItemCell {
    var thumbnailImageView: UIImageView! { get set }
    var titleLabel: UILabel! { get set }
    var priceLabel: UILabel! { get set }
    var stockLabel: UILabel! { get set }
    
    
    func updateContent(at indexPath: IndexPath, items: [Page.Item]?, collectionView: UICollectionView)
}
