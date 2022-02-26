//  Created by Axel Ancona Esselmann on 2/25/22.
//

import Foundation
import ThrottledTask

struct MockNetworking {
    
    let taskCache: TaskCache<Request, MockResultType>
    
    enum Error: Swift.Error {
        case invalidTypeRequested
    }
    
    func fetch<Result>(_ request: Request, validFor seconds: TimeInterval = 0) async throws -> Result where Result: MockResultType {
        try await taskCache.addTask(for: request, validFor: seconds) {
            try await mockRequest(request) as Result
        }
    }
}

fileprivate extension MockNetworking {
    func mockRequest<Result>(_ request: Request) async throws -> Result where Result: MockResultType {
        print("Fetching \(request)")
        let seconds = 3.0
        try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
        let returned: Any
        switch request {
        case .randomInt(range: let closedRange): returned = Int.random(in: closedRange)
        case .randomString(lenght: let length):  returned = String.random(length: length)
        case .randomBool:                        returned = Bool.random()
        }
        print("Fetched \(returned)")
        if let result = returned as? Result {
            return result
        } else {
            throw Error.invalidTypeRequested
        }
    }
}

extension String {
    static func random(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }
}

enum Request: CustomStringConvertible {
    case randomInt(range: ClosedRange<Int>)
    case randomString(lenght: Int)
    case randomBool
    
    var description: String {
        switch self {
        case .randomInt(range: let range):
            return "Random integer with range \(range)"
        case .randomString(lenght: let lenght):
            return "Random string with length \(lenght)"
        case .randomBool:
            return "Random bool"
        }
    }
    
    var url: URL {
        switch self {
        case .randomInt(range: let range):
            return URL(string: "randomInt?lower=\(range.lowerBound)&upper=\(range.upperBound)")!
        case .randomString(lenght: let lenght):
            return URL(string: "randomString?length=\(lenght)")!
        case .randomBool:
            return URL(string: "randomBool")!
        }
    }
}

extension Request: Hashable {
    var stringValue: String {
        url.absoluteString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stringValue)
    }
}

protocol MockResultType {
    var stringValue: String { get }
}

extension Int: MockResultType {
    var stringValue: String { "\(self)" }
}

extension String: MockResultType {
    var stringValue: String { self }
}

extension Bool: MockResultType {
    var stringValue: String { "\(self)" }
}
