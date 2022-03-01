//  Created by Axel Ancona Esselmann on 2/25/22.
//

import Foundation

public actor TaskCache<Key, TaskType> where Key: Hashable {
    public typealias Operation = @Sendable () async throws -> TaskType
    
    public enum Error: Swift.Error {
        case invalidType
        case cacheError
    }
    
    private let cache: NSCache<NSString, AnyObject>
    
    public init(countLimit: Int? = nil) {
        cache = {
            let cache = NSCache<NSString, AnyObject>()
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
        let value: Value?
        if let expiration = expiration {
            value = try await throttledTask(for: key, validUntil: expiration, operation: operation).value as? Value
        } else {
            value = try await synchronizedTask(for: key, operation: operation).value as? Value
        }
        guard let value = value else {
            throw Error.invalidType
        }
        return value
    }

    private func synchronizedTask(
        for key: Key,
        operation: @escaping Operation
    ) -> SynchronizedTask<TaskType> {
        let nsStringKey = NSString(string: String(key.hashValue))
        if let cached = cache.object(forKey: nsStringKey) as? SynchronizedTask<TaskType> {
            return cached
        } else {
            let new = SynchronizedTask<TaskType>(operation: operation)
            cache.setObject(new, forKey: nsStringKey)
            return new
        }
    }

    private func throttledTask(
        for key: Key,
        validUntil expiration: Date,
        operation: @escaping Operation
    ) -> ThrottledTask<TaskType> {
        let nsStringKey = NSString(string: String(key.hashValue))
        if let cached = cache.object(forKey: nsStringKey) as? ThrottledTask<TaskType>, cached.expiration.isFutureDate {
            return cached
        } else {
            let new = ThrottledTask<TaskType>(expiration: expiration, operation: operation)
            cache.setObject(new, forKey: nsStringKey)
            return new
        }
    }

}
