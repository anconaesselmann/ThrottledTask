//  Created by Axel Ancona Esselmann on 2/25/22.
//

import Foundation
import ThrottledTask

struct Networking {
    
    let taskCache: TaskCache<Request, Codable>
    
    enum Error: Swift.Error {
        case invalidTypeRequested
    }
    
    func throttledFetch<Result>(_ request: Request, validFor seconds: TimeInterval = 0) async throws -> Result where Result: Codable {
        try await taskCache.addTask(for: request, validFor: seconds) {
            try await fetch(request) as Result
        }
    }
    
    var mockDelay: () -> TimeInterval
}
