//
//  SBPViewItem.swift
//
//
//  Created by Sergey Panov on 28.09.2022.
//

import Foundation

struct SBPBankViewItem: Hashable {
    var id = UUID()
    var bank: SBPBank
    
    init(with item: SBPBank) {
        self.bank = item
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    static func == (lhs: SBPBankViewItem, rhs: SBPBankViewItem) -> Bool {
      lhs.id == rhs.id
    }
}
