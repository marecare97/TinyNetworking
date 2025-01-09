//
//  TinyNetworking.swift
//  TinyNetworking
//
//  Created by Joan Disho on 02.03.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation
import os

@available(OSX 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)

public class HTTPClient<R: HTTPResource>: HTTPClientType {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: HTTPClient.self))
    
    public init() {}
    
    public func requestAsync(
        resource: R,
        session: HTTPClientSession = URLSession.shared
    ) async -> Result<HTTPResponse, HTTPError> {
        let result = await executeRequest(resource: resource, session: session)
        if case .failure(let error) = result, resource.shouldRetry(from: error) {
            await resource.retryCallback(httpClient: self)
            return await executeRequest(resource: resource, session: session)
        }
        return result
    }
    
    private func executeRequest(resource: any HTTPResource, session: HTTPClientSession) async -> Result<HTTPResponse, HTTPError> {
        var request = URLRequest(resource: resource)
        if resource.isAuthorized {
            resource.authorize(request: &request)
        }
        logger.logRequest(request)
        let (response, error) = await session.loadDataAsync(with: request)
        if error != nil {
            logger.logError(response, error!)
            return .failure(.networkLayer(error!, response))
        } else {
            guard
                let httpURLResponse = response.httpURLResponse,
                200..<300 ~= httpURLResponse.statusCode else {
                logger.logError(response, HTTPError.statusCode(response))
                return .failure(.statusCode(response))
            }
            logger.logResponse(response)
            return .success(response)
        }
    }
}

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var successValue: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
}

