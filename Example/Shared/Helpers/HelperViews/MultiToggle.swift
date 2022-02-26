//  Created by Axel Ancona Esselmann on 2/28/22.
//

import SwiftUI

struct MultiToggle<ToggleStateType>: View where ToggleStateType: ToggleState {
    
    @Binding var toggleState: ToggleStateType

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<ToggleStateType.count) { index in
                GeometryReader { proxy in
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    Group {
                        if ToggleStateType.index(of: toggleState) == index {
                            toggleView
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                            )
                        } else {
                            backgroundButton(state: .init(rawValue: index)!)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                }
                }
            }
        }.clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    var toggleView: some View {
        let next = toggleState.next
        
        return Button {
            withAnimation {
                toggleState = next
            }
        } label: {
            Text("\(toggleState.description)").foregroundColor(.white)
        }
    }
    
    func backgroundButton(state: ToggleStateType) -> some View {
        return Button {
            withAnimation {
                toggleState = state
            }
        } label: {
            Text("\(state.description)").foregroundColor(.white)
        }
    }
    
}

protocol ToggleState {
    var next: Self { get }
    static var count: Int { get }
    static func index(of element: Self) -> Int
    init?(rawValue: Int)
    var description: String { get }
}

extension ToggleState where Self: CaseIterable, Self: Equatable {
    var next: Self {
        let allCases = Self.allCases
        let currentIndex = allCases.firstIndex(where: { self == $0 })!
        var nextIndex = allCases.index(after: currentIndex)
        if nextIndex >= allCases.endIndex {
            nextIndex = allCases.startIndex
        }
        return allCases[nextIndex]
    }
    
    static var count: Int {
        allCases.count
    }
    
    static func index(of element: Self) -> Int {
        return allCases.distance(from: allCases.startIndex, to: allCases.firstIndex(where: { element == $0 })!)
    }
}

struct MultiToggle_Previews: PreviewProvider {
    @State static var isShowing = true
    @State static var requestType: Request = .randomBool
    static var previews: some View {
        CreateTask(isShowing: $isShowing, requestType: $requestType)
    }
}
