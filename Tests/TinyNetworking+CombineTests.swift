//
//  TinyNetworking+CombineTests.swift
//  TinyNetworkingTests
//
//  Created by Alan Steiman on 08/04/2020.
//  Copyright © 2020 Joan Disho. All rights reserved.
//

#if canImport(Combine)

import XCTest
import Combine
@testable import TinyNetworking

@available(OSX 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
class TinyNetworkingCombineTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    let network = TinyNetworking<FooResource>()
    
    func test_requestPublisher_success() {
        let returnData = Data(base64Encoded: "response")
        let mockSession = MockSession(input: MockSession.Input(data: returnData, httpURLResponse: HTTPURLResponse(url: URL(string: "https://mocky.io")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil))
        network.requestPublisher(resource: .getEndpointQueryParams, session: mockSession, queue: .main).sink(receiveCompletion: { _ in
            //
        }) { receivedValue in
            XCTAssertEqual(receivedValue.data, returnData)
        }.store(in: &cancellables)
    }
    
    func test_requestPublisher_error() {
        let mockSession = MockSession(input: MockSession.Input(data: nil, httpURLResponse: HTTPURLResponse(url: URL(string: "https://mocky.io")!, statusCode: 500, httpVersion: nil, headerFields: nil), error: nil))
        network.requestPublisher(resource: .getEndpointQueryParams, session: mockSession, queue: .main).sink(receiveCompletion: { completion in
            switch completion {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError.errorDescription, "Status code didn\'t fall within the given range.")
            default:
                XCTFail("Should receive error")
            }
        }) { receivedValue in
            XCTFail("Should not receive value")
        }.store(in: &cancellables)
    }
    
    func test_map_success() {
        let fooInstance = FooEncodable()
        
        let mockSession = MockSession(input: MockSession.Input(data: fooInstance.data, httpURLResponse: HTTPURLResponse(url: URL(string: "https://mocky.io")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil))
        
        let expectation = XCTestExpectation(description: "Completion")
        network.requestPublisher(resource: .getEndpointQueryParams, session: mockSession, queue: .main)
            .map(to: FooEncodable.self)
            .sinkToResult { result in
                result.assertSuccess(value: fooInstance)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_map_failure_unhandledError() {
        let fooInstance = FooEncodable()

        let mockSession = MockSession(input: MockSession.Input(data: fooInstance.data, httpURLResponse: HTTPURLResponse(url: URL(string: "https://mocky.io")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: FooError.someError))
        
        let expectation = XCTestExpectation(description: "Completion")
        network.requestPublisher(resource: .getEndpointQueryParams, session: mockSession, queue: .main)
            .map(to: BarEncodable.self)
            .sinkToResult { result in
                result.assertFailure("The operation couldn’t be completed. (TinyNetworkingTests.FooError error 0.)")
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_map_failure_underlyingError() {
        let fooInstance = FooEncodable()

        let mockSession = MockSession(input: MockSession.Input(data: fooInstance.data, httpURLResponse: HTTPURLResponse(url: URL(string: "https://mocky.io")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil))
        
        let expectation = XCTestExpectation(description: "Completion")
        network.requestPublisher(resource: .getEndpointQueryParams, session: mockSession, queue: .main)
            .map(to: BarEncodable.self)
            .sinkToResult { result in
                result.assertFailure("The data couldn’t be read because it is missing.")
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}

#endif
