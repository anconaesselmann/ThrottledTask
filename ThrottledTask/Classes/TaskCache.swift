//  Created by Axel Ancona Esselmann on 2/25/22.
//

import Foundation

public actor TaskCache<Key, TaskType> where Key: Hashable {
    public typealias Operation = @Sendable () async throws -> TaskType
    
    public enum Error: Swift.Error {
        case invalidType
        case cacheError
    }
    
    private let cache: NSCache<NSString, ThrottledTask<TaskType>>
    
    public init(countLimit: Int? = nil) {
        cache = {
            let cache = NSCache<NSString, ThrottledTask<TaskType>>()
            if let countLimit = countLimit {
                cache.countLimit = countLimit
            }
            return cache
        }()
    }
    
    public func addTask<Value>(
        for key: Key,
        validFor seconds: TimeInterval = 0,
        operation: @escaping Operation
    ) async throws -> Value {
        let expiration = seconds > 0 ? Date().addingTimeInterval(seconds) : nil
        return try await addTask(for: key, validUntil: expiration, operation: operation)
    }
    
    public func addTask<Value>(
        for key: Key,
        validUntil expiration: Date? = nil,
        operation: @escaping Operation
    ) async throws -> Value {
        let throttledTask = throttledTask(for: key)
        if let result = try await throttledTask.subscribe(until: expiration, operation: operation) as? Value {
            return result
        } else {
            throw Error.invalidType
        }
    }
    
    private func throttledTask(for key: Key) -> ThrottledTask<TaskType> {
        let nsStringKey = NSString(string: String(key.hashValue))
        if let cached = cache.object(forKey: nsStringKey) {
            return cached
        } else {
            let new = ThrottledTask<TaskType>()
            cache.setObject(new, forKey: nsStringKey)
            return new
        }
    }

}
