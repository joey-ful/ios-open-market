//
//  ItemAPIProvider.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/11.
//

import Foundation

typealias Parameters = [String:Any]

struct NetworkManager {
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func sendRequest<T: Decodable>(
        httpRequest: HTTPRequest,
        url: URL,
        withParameters parameters: Parameters?,
        images: [Media]?,
        completion: @escaping (Result<T, Error>) -> Void)
    {
        let request = httpRequest.createURLRequest(url: url, withParameters: parameters, media: images)
        
        session.dataTaskWithRequest(with: request) { responseData, urlResponse, responseError in
            var data = Data()
            do {
                data = try obtainResponseData(data: responseData,
                                              response: urlResponse,
                                              error: responseError)
                
                let parsedResult = data.parse(type: T.self)

                switch parsedResult {
                case .success(let decodedData):
                    completion(.success(decodedData))
                case .failure(let error):
                    completion(.failure(error))
                }
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func obtainResponseData(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
        if let error = error {
            throw error
        }
        
        print(response!)
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard let data = data else {
            throw NetworkError.dataNotFound
        }
        
        return data
    }
}
