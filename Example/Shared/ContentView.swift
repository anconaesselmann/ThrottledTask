//  Created by Axel Ancona Esselmann on 2/25/22.
//

import SwiftUI
import ThrottledTask

struct ContentView: View {
    
    @State var taskCache = TaskCache<Request, MockResultType>()
    
    var body: some View {
        List {
            let networking = MockNetworking(taskCache: taskCache)
            ForEach(0..<5) { _ in
                ExampleView<Int>(networking: networking, request: .randomInt(range: 0...10))
            }
            ForEach(0..<5) { _ in
                ExampleView<Int>(networking: networking, request: .randomInt(range: 11...20))
            }
            ForEach(0..<5) { _ in
                ExampleView<String>(networking: networking, request: .randomString(lenght: 5))
            }
            ForEach(0..<5) { _ in
                ExampleView<String>(networking: networking, request: .randomString(lenght: 10))
            }
            ForEach(0..<5) { _ in
                ExampleView<Bool>(networking: networking, request: .randomBool)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
