//
//  URLSessionProtocol.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/11.
//

import Foundation

protocol URLSessionProtocol {
    func dataTaskWithRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTaskWithRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
}
