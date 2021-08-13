//
//  MockURLSession.swift
//  OpenMarketTests
//
//  Created by Dasoll Park on 2021/08/13.
//

import Foundation
@testable import OpenMarket

class MockURLSession: URLSessionProtocol {
    func dataTaskWithRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let url = request.url ?? URL(string: "")!
        let successResponse = HTTPURLResponse(url: url,
                                              statusCode: 200,
                                              httpVersion: "2",
                                              headerFields: nil)
        let failureResponse = HTTPURLResponse(url: url,
                                              statusCode: 404,
                                              httpVersion: "2",
                                              headerFields: nil)
        let sessionDataTask = MockURLSessionDataTask()
        
        guard let data = obtainData(of: url) else {
            sessionDataTask.resumeDidCall = {
                completionHandler(nil, failureResponse, nil)
            }
            return sessionDataTask
        }
        sessionDataTask.resumeDidCall = {
            completionHandler(data, successResponse, nil)
        }
        return sessionDataTask
    }
    
    func obtainData(of url: URL) -> Data? {
        return Data()
    }
}