//
//  TinyNetworkingPublisher.swift
//  TinyNetworking
//
//  Created by Joan Disho on 04.09.19.
//  Copyright © 2019 Joan Disho. All rights reserved.
//

#if canImport(Combine)

import Foundation
import Combine

@available(OSX 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
internal class HTTPClientPublisher<Output, Failure>: Publisher where Failure: Swift.Error {
    private let task: (AnySubscriber<Output, Failure>) -> Task<Void, Never>?

    init(task: @escaping (AnySubscriber<Output, Failure>) -> Task<Void, Never>?) {
        self.task = task
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber), callback: task)
        subscriber.receive(subscription: subscription)
    }
}

@available(OSX 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
private extension HTTPClientPublisher {
    class Subscription: Combine.Subscription {

        private let task: Task<Void, Never>?

        init(subscriber: AnySubscriber<Output, Failure>, callback: @escaping (AnySubscriber<Output, Failure>) -> Task<Void, Never>?) {
            task = callback(subscriber)
        }

        func request(_ demand: Subscribers.Demand) {
            // We don't care for the demand.
        }

        func cancel() {
            task?.cancel()
        }
    }
}

#endif
