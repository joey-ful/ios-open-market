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
    
    // TODO: - URL의 형식에 따라 타입을 결정해주는 로직
    /// MARK: GET
    func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task: URLSessionDataTaskProtocol = session
            .dataTaskWithRequest(with: request) { responseData, urlResponse, responseError in
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
            }
        task.resume()
    }
    
    func obtainResponseData(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
        if let error = error {
            throw error
        }
        
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard let data = data else {
            throw NetworkError.dataNotFound
        }
        
        return data
    }
    
    ///MARK: DELETE
    func deleteData(url: URL, parameters: [String:String]) {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dataBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = dataBody!
        
        sessionDataTaskAndPrintResults(with: request)
    }
    
    //MARK:PATCH
    func patchData(url: URL, parameters: [String:Any], images: [Media]?) {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let dataBody = createDataBody(withParameters: parameters, media: images, boundary: boundary)
        request.httpBody = dataBody
        
        sessionDataTaskAndPrintResults(with: request)
    }
    
    //MARK:POST
    func postData(url: URL, parameters: [String:Any], images: [Media]?) {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let dataBody = createDataBody(withParameters: parameters, media: images, boundary: boundary)
        request.httpBody = dataBody
        
        sessionDataTaskAndPrintResults(with: request)
    }

    //MARK:multipart
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)\(lineBreak)")
            }
        }
        
        if let media = media {
            for image in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(image.mimeType + lineBreak + lineBreak)")
                body.append(image.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    //MARK: SessionDataTask
    func sessionDataTaskAndPrintResults(with request: URLRequest) {
        session.dataTaskWithRequest(with: request) { data, response, error in
            guard error == nil else { return }
            print(response!)
            
            guard let statudCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statudCode) else { return }
            guard let data = data else { return }
            
            let serialized = try? JSONSerialization.jsonObject(with: data, options: [])
            print(serialized!)
            
        }.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
