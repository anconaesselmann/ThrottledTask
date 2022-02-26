//  Created by Axel Ancona Esselmann on 2/25/22.
//

import SwiftUI

class ExampleViewModel<Element>: ObservableObject where Element: MockResultType {
    
    enum ViewState {
        case notStarted
        case started
        case success(Element)
        case error(Error)
    }
    
    let networking: Networking
    let request: Request
    
    @Published var viewState: ViewState = .notStarted
    
    var throttle: () -> Double
    
    init(networking: Networking, request: Request, throttle: @escaping () -> Double) {
        self.networking = networking
        self.request = request
        self.throttle = throttle
    }
    
    func makeRequest() {
        viewState = .started
        Task {
            do {
                let element = try await self.networking.throttledFetch(request, validFor: throttle()) as Element
                await MainActor.run {
                    viewState = .success(element)
                }
            } catch {
                await MainActor.run {
                    viewState = .error(error)
                }
            }
        }
    }
}
