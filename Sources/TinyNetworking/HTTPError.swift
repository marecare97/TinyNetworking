//
//  TinyNetworkingError.swift
//  TinyNetworking
//
//  Created by Joan Disho on 12.09.19.
//  Copyright © 2019 Joan Disho. All rights reserved.
//

import Foundation

public enum HTTPError: Swift.Error {
    case noData(HTTPResponse)
    case statusCode(HTTPResponse)
    case decoding(Swift.Error, HTTPResponse)
    case networkLayer(Swift.Error, HTTPResponse?)
}

public extension HTTPError {
    var response: HTTPResponse? {
        switch self {
        case let .noData(response):
            return response
        case let .statusCode(response):
            return response
        case let .decoding(_, response):
            return response
        case let .networkLayer(_, response):
            return response
        }
    }
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "The request gave no data."
        case .statusCode:
            return "Status code didn't fall within the given range."
        case .decoding:
            return "Failed to map data to a Decodable object."
        case let .networkLayer(error, _):
            return error.localizedDescription
        }
    }
}
