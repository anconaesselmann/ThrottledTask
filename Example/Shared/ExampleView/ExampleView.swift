//  Created by Axel Ancona Esselmann on 2/25/22.
//

import SwiftUI

struct ExampleView<RequestType>: View, Identifiable where RequestType: MockResultType {
    
    @StateObject var viewModel: ExampleViewModel<RequestType>
    
    let id = UUID()
    
    init(networking: Networking, request: Request, throttle: @escaping () -> Double) {
        _viewModel = StateObject(wrappedValue: ExampleViewModel<RequestType>(networking: networking, request: request, throttle: throttle))
    }
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .notStarted:
                Button("Request: \(viewModel.request.description)") {
                    viewModel.makeRequest()
                }
            case .started:
                Text("Subscribed")
            case .success(let element):
                Text("Result: \(element.stringValue)")
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
            }
        }
    }
}
