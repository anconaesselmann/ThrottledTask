//  Created by Axel Ancona Esselmann on 2/25/22.
//

import Foundation

public extension Date {
    var isFutureDate: Bool {
        self > Date()
    }
}

public actor ThrottledTask<Element> {
    public typealias Operation = @Sendable () async throws -> Element
    private typealias _Task = Task<Element, Error>
    
    private var task: _Task?
    private var expiration: Date?
    
    private let priority: TaskPriority?
    
    public init(priority: TaskPriority? = nil) {
        self.priority = priority
    }
    
    public var isValid: Bool {
        expiration?.isFutureDate ?? false
    }
    
    public func subscribe(
        forSeconds seconds: TimeInterval = 0,
        operation: @escaping Operation
    ) async throws -> Element {
        let expiration = seconds > 0 ? Date().addingTimeInterval(seconds) : nil
        return try await subscribe(
            until: expiration,
            operation: operation
        )
    }
    
    public func subscribe(
        until expiration: Date?,
        operation: @escaping Operation
    ) async throws -> Element {
        if expiration != nil, !isValid {
            reset()
        }
        return try await task(
            until: expiration,
            priority: priority,
            operation: operation
        ).value
    }
    
    private func reset() {
        self.task = nil
        self.expiration = nil
    }
    
    private func task(
        until expiration: Date?,
        priority: TaskPriority?,
        operation: @escaping () async throws -> Element
    ) -> _Task {
        if let task = self.task {
            return task
        } else {
            let task = self.task ?? _Task(priority: priority) {
                let result = try await operation()
                if expiration == nil {
                    reset()
                }
                return result
            }
            self.expiration = expiration
            self.task = task
            return task
        }
    }
}
