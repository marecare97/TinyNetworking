//
//  TinyNetworking+Combine.swift
//  TinyNetworking
//
//  Created by Joan Disho on 04.09.19.
//  Copyright © 2019 Joan Disho. All rights reserved.
//

#if canImport(Combine)

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension HTTPClient {
    
    func requestPublisher(
        resource: R,
        session: HTTPClientSession = URLSession.shared,
        queue: DispatchQueue = .main
    ) -> AnyPublisher<HTTPResponse, HTTPError> {
        let publisher = HTTPClientPublisher<HTTPResponse, HTTPError> { [weak self] subscriber in
            return Task {
                guard let self = self else { return }
                let result = await self.requestAsync(resource: resource, session: session)
                switch result {
                case let .success(response):
                    _ = subscriber.receive(response)
                    subscriber.receive(completion: .finished)
                case let .failure(error):
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
        return publisher.eraseToAnyPublisher()
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AnyPublisher where Output == HTTPResponse, Failure == HTTPError {
    
    func map<D: Decodable>(to type: D.Type, decoder: JSONDecoder = .init()) -> AnyPublisher<D, HTTPError> {
        return self
            .filter { $0.data != nil }
            .tryMap { response in
                do {
                    let output = try decoder.decode(D.self, from: response.data!)
                    return output
                } catch {
                    throw HTTPError.decoding(error, response)
                }
            }
            .mapError { error -> HTTPError in
                guard let httpError = error as? HTTPError else {
                    return .networkLayer(error, nil)
                }
                return httpError
            }
            .eraseToAnyPublisher()
    }
}


#endif
