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
    
    let networking: MockNetworking
    let request: Request
    
    @Published var viewState: ViewState = .notStarted
    
    init(networking: MockNetworking, request: Request) {
        self.networking = networking
        self.request = request
    }
    
    func makeRequest() {
        viewState = .started
        Task {
            do {
                let element = try await self.networking.fetch(request) as Element
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
