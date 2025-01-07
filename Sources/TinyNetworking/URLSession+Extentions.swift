//
//  URLSession+Extentions.swift
//  TinyNetworking
//
//  Created by Joan Disho on 07.04.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation

public protocol HTTPClientSession {
    
    typealias CompletionHandler = (HTTPResponse, Swift.Error?) -> Void
    
    func loadDataAsync(with urlRequest: URLRequest) async -> (HTTPResponse, Swift.Error?)
}

extension URLSession: HTTPClientSession {
    
    public func loadDataAsync(with urlRequest: URLRequest) async -> (HTTPResponse, Swift.Error?) {
        do {
            let response = try await data(for: urlRequest)
            return (HTTPResponse(
                urlRequest: urlRequest,
                data: response.0,
                httpURLResponse: response.1 as? HTTPURLResponse
            ), nil)
        } catch {
            return (HTTPResponse(
                urlRequest: urlRequest,
                data: nil,
                httpURLResponse: nil
            ), error)
        }
    }
}
