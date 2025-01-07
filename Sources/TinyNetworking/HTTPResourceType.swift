//
//  ResourceType.swift
//  TinyNetworking
//
//  Created by Joan Disho on 29.03.18.
//

import Foundation

public protocol HTTPResource {
    
    var baseURL: URL { get }
    var endpoint: HTTPEndpoint { get }
    var task: HTTPClientTask { get }
    var headers: [String: String] { get }
    var isAuthorized: Bool { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    func authorize(request: inout URLRequest)
    func retryCallback(httpClient: HTTPClient<Self>) async
    func shouldRetry(from error: HTTPError) -> Bool
}

public extension HTTPResource {
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
}

