//
//  TinyNetworkingType.swift
//  TinyNetworking
//
//  Created by Joan Disho on 29.03.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation

public protocol HTTPClientType {

    associatedtype Resource
    
    func requestAsync(
        resource: Resource,
        session: HTTPClientSession
    ) async -> Result<HTTPResponse, HTTPError>
}
