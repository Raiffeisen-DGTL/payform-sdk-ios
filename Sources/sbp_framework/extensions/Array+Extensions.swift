//
//  Array+Extensions.swift
//  sbp_framework
//
//  Created by Sergey Panov on 03.10.2022.
//

import Foundation

extension Array where Element:Equatable {

    func prefixWithoutDuplicates(_ maxLength: Int) -> [Element] {
        var result = [Element]()
        var index = 0
        
        while (result.count < maxLength && index < self.count) {
            if result.contains(self[index]) == false {
                result.append(self[index])
            }
            index += 1
        }
        
        return result
    }
    
    mutating func updateDifference(with newArray: [Element], by areEquivalent: (Element, Element) -> Bool) {
        var difference = newArray.difference(from: self, by: areEquivalent)
    
        while !difference.isEmpty {
            switch difference.first {
            case let .remove(offset, _, _):
                self.remove(at: offset)
            case let .insert(offset, newElement, _):
                self.insert(newElement, at: offset)
            case .none:
                break
            }
            difference = newArray.difference(from: self, by: areEquivalent)
        }
    }
}
