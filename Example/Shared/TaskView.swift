//  Created by Axel Ancona Esselmann on 2/25/22.
//

import SwiftUI
import ThrottledTask

struct TaskView: View {
    
    var taskCache = TaskCache<Request, Codable>()
    
    @State var networkingResponse: Double = 3
    @State var validForSeconds: Double = 0.0
    
    @State var showingSheet = false
    
    @State var requests: [IdentifiableWrapper<Request>] = []
    @State var requestType: Request = .randomInt(range: 0...10)
    
    var body: some View {
        List {
            Section("Settings") {
                Text("Mock network delay: \(networkingResponse.formatted(decimalPlaces: 1)) seconds")
                    .padding()
                Slider(value: $networkingResponse, in: 0...10)
                Text("Throttle duration: \(validForSeconds.formatted(decimalPlaces: 1)) seconds")
                    .padding()
                Text({ () -> String in
                    if validForSeconds == 0 {
                        return "The first task initiates a request. All tasks created while the request has not returned will await the result of the request and return when the request returns. The first task created after the request has returned will create a new request, which starts the process over."
                    } else if validForSeconds < networkingResponse {
                        return "Requests take longer to return than the throttle duration. All tasks created in the throttle window will return together and only one request gets created. The first task created after the throttle duration has passed but before the previous request has returned will create a new group of taks that also return together."
                    } else {
                        return "All tasks made during the throttle window will create one request. If the request has come back and additional tasks are created before the throttle window has expired they will return the result of the initial request"
                    }}())
                Slider(value: $validForSeconds, in: 0...10)
                    .padding()
            }
            Section("Tasks") {
                ForEach(requests) { wrapper in
                    
                    let request = wrapper.wrappedValue
                    let networking = Networking(taskCache: taskCache, mockDelay: { networkingResponse })
                    let throttle = { validForSeconds }
                    Group {
                        switch request {
                        case .randomInt:
                            ExampleView<Int>(networking: networking, request: request, throttle: throttle)
                        case .randomString:
                            ExampleView<String>(networking: networking, request: request, throttle: throttle)
                        case .randomBool:
                            ExampleView<Bool>(networking: networking, request: request, throttle: throttle)
                        }
                    }.swipeActions {
                        Button {
                            withAnimation {
                                requests.removeAll(where: { $0.id == wrapper.id })
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }.tint(.red)
                    }.swipeActions {
                        Button {
                            withAnimation {
                                guard let index = requests.firstIndex(where: { $0.id == wrapper.id }) else {
                                    return
                                }
                                requests[index] = IdentifiableWrapper(wrappedValue: request)
                            }
                        } label: {
                            Label("Refresh", systemImage: "arrow.counterclockwise")
                        }.tint(.blue)
                    }
                }
            }
        }.sheet(isPresented: $showingSheet) {
            CreateTask(isShowing: $showingSheet, requestType: $requestType)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button("Add task") {
                        print("Pressed")
                        requests = [IdentifiableWrapper(wrappedValue: requestType)] + requests
                    }
                    Spacer()
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}
