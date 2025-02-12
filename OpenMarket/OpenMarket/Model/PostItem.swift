//
//  PostItem.swift
//  OpenMarket
//
//  Created by Dasoll Park on 2021/08/11.
//

import Foundation

struct PostItem: Encodable {
    let title: String
    let descriptions: String
    let price: Int
    let currency: String
    let stock: Int
    let discountedPrice: Int?
    let images: [Data]
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case title, descriptions, price, currency, stock, images, password
        case discountedPrice = "discounted_price"
    }
}
