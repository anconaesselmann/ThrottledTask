//  Created by Axel Ancona Esselmann on 2/25/22.
//

import Foundation

public extension Date {
    var isFutureDate: Bool {
        self > Date()
    }
}

public protocol TaskProtocol {
    associatedtype Element
    var value: Element { get async throws }
}

public actor SynchronizedTask<Element>: TaskProtocol {
    public typealias Operation = @Sendable () async throws -> Element
    private typealias _Task = Task<Element, Error>

    private var task: _Task?

    private let operation: Operation
    private let resets: Bool

    public var value: Element {
        get async throws {
            if let task = task {
                return try await task.value
            } else {
                let task = _Task {
                    let result = try await operation()
                    reset()
                    return result
                }
                self.task = task
                return try await task.value
            }
        }
    }

    public init(operation: @escaping Operation, resets: Bool = true) {
        self.operation = operation
        self.resets = resets
    }

    private func reset() {
        if resets {
            task = nil
        }
    }
}

public actor ThrottledTask<Element> {
    public typealias Operation = @Sendable () async throws -> Element
    private typealias _Task = Task<Element, Error>

    public let expiration: Date

    private var task: _Task?
    private let operation: Operation

    public var value: Element {
        get async throws {
            if let task = task {
                return try await task.value
            } else {
                let task = _Task {
                    let result = try await operation()
                    reset()
                    return result
                }
                self.task = task
                return try await task.value
            }
        }
    }
    
    public init(expiration: Date, operation: @escaping Operation) {
        self.expiration = expiration
        self.operation = operation
    }

    private func reset() {
        if !expiration.isFutureDate {
            self.task = nil
        }
    }
}
