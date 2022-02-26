//  Created by Axel Ancona Esselmann on 2/28/22.
//

import Foundation

extension Networking {
    func fetch<Result>(_ request: Request) async throws -> Result where Result: Codable {
        let delay = mockDelay()
        print("Fetching \(request) with delay of \(delay.formatted(decimalPlaces: 1)) seconds")
        try await Task.sleep(nanoseconds: UInt64(delay * Double(NSEC_PER_SEC)))
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
    
    enum Case: Int, CaseIterable { case randomInt, randomString, randomBool }
    
    var `case`: Case {
        switch self {
        case .randomInt: return .randomInt
        case .randomString: return .randomString
        case .randomBool: return .randomBool
        }
    }
    
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

protocol MockResultType: Codable {
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
