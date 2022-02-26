//  Created by Axel Ancona Esselmann on 2/28/22.
//

import Foundation

extension Double {
    func rounded(_ decimalPlaces: Int) -> Double {
        let factor: Double = pow(10.0, Double(decimalPlaces))
        return (self * factor).rounded() / factor
    }
    
    func formatted(decimalPlaces: Int) -> String {
        rounded(decimalPlaces).formatted()
    }
}

struct IdentifiableWrapper<Value>: Identifiable {
    let id = UUID()
    let wrappedValue: Value
}
