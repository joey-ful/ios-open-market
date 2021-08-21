//
//  HTTPRequest.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/21.
//

import Foundation

enum HTTPRequest: String {
    case get, post, patch, delete
    
    var method: String {
        return self.rawValue.uppercased()
    }
    
    func createURLRequest(url: URL,
                       withParameters parameters: Parameters?,
                       media: [Media]?) -> URLRequest
    {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod = self.method
        
        switch self {
        case .post, .patch:
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = createMultipartFormDataBody(withParameters: parameters, media: media, boundary: boundary)
        case .delete:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters ?? [:], options: [])
        case .get: break
        }
        
        return request
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    private func createMultipartFormDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
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
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
