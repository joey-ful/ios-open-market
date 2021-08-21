//
//  HTTPMethodEnum.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/21.
//

import Foundation

enum HTTPRequest: String {
    case get
    case post
    case patch
    case delete
    
    var method: String {
        return self.rawValue.uppercased()
    }
    
    func assembleURLRequest(of url: URL, withParameters parameters: Parameters?, media: [Media]?, boundary: String) -> URLRequest {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod = self.method
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let dataBody = createDataBody(withParameters: parameters, media: images, boundary: boundary)
        request.httpBody = dataBody
        
        sessionDataTaskAndPrintResults(with: request)
    }
    
    func setContentType: String {
        case .get {
            return "multipart/form-data; boundary=\(boundary)"
        }
    }
    
    func setHTTPBody(withParameters parameters: Parameters?, media: [Media]?, boundary: String) -> Data? {
        switch self {
        case .get:
            return nil
        case .post, .patch:
            return createDataBody(withParameters: parameters, media: media, boundary: String)
        case .delete:
            return nil
        }
    }
    
    func createURLRequest(url: URL, parameters: [String:Any], images: [Media]?) {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let dataBody = createDataBody(withParameters: parameters, media: images, boundary: boundary)
        request.httpBody = dataBody
        
        sessionDataTaskAndPrintResults(with: request)
    }
    
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
