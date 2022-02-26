//  Created by Axel Ancona Esselmann on 2/28/22.
//

import SwiftUI

extension Request.Case: ToggleState, CustomStringConvertible {
    var description: String {
        switch self {
        case .randomInt: return "int"
        case .randomString: return "string"
        case .randomBool: return "double"
        }
    }
}

struct CreateTask: View {
    
    @Binding var isShowing: Bool
    @Binding var requestType: Request
    
    @State var length: Int
    @State var range: ClosedRange<Int>
    
    init(isShowing: Binding<Bool>, requestType: Binding<Request>) {
        _isShowing = isShowing
        _requestType = requestType
        let defaultRange = 0...10
        let deraultLength = 5
        switch requestType.wrappedValue {
        case .randomInt(let range):
            self.length = deraultLength
            self.range = range
        case .randomString(let length):
            self.length = length
            self.range = defaultRange
        case .randomBool:
            self.length = deraultLength
            self.range = defaultRange
        }
        print(length, range, requestType.wrappedValue)
    }
    
    var body: some View {
        VStack {
            Text("Create a task:")
                .padding()
            MultiToggle(toggleState: Binding(get: {
                 requestType.case
            }, set: { (new: Request.Case) -> () in
                switch new {
                case .randomBool: requestType = .randomBool
                case .randomInt: requestType = .randomInt(range: range)
                case .randomString: requestType = .randomString(lenght: length)
                }
            })).frame(width: 300, height: 50)
            switch requestType {
            case .randomInt:
                TextField("Lower Bound", text: Binding(
                    get: { String(range.lowerBound.formatted()) },
                    set: {
                        guard let new = Int($0), new < range.upperBound else { return }
                        range = new...range.upperBound
                        requestType = .randomInt(range: range)
                    }
                )).textFieldStyle(.roundedBorder).padding()
                TextField("Upper Bound", text: Binding(
                    get: { String(range.upperBound.formatted()) },
                    set: {
                        guard let new = Int($0), new > range.lowerBound else { return }
                        range = range.lowerBound...new
                        requestType = .randomInt(range: range)
                    }
                )).textFieldStyle(.roundedBorder).padding()
            case .randomString:
                TextField("Length", text: Binding(
                    get: { String(length.formatted()) },
                    set: {
                        guard let new = Int($0) else { return }
                        length = new
                        requestType = .randomString(lenght: new)
                    }
                )).textFieldStyle(.roundedBorder).padding()
            case .randomBool:
                EmptyView()
            }
            Button {
                isShowing = false
            } label: {
                Text("Done")
            }
            Spacer()
        }
    }
}
