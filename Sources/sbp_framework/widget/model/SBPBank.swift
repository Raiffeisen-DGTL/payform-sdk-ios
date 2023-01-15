//
//  SBPBank.swift
//
//
//  Created by Sergey Panov on 27.09.2022.
//

import Foundation
import UIKit

class SBPBank {
    let bankName: String
    let logoURL: String
    let schema: String
    var isInstalled: Bool = false
    var numUsed: Int = 0
    
    public init(bank: SBPBankResponse) {
        self.bankName = bank.bankName
        self.logoURL = bank.logoURL
        self.schema = bank.schema
        self.isInstalled = checkiOSApplication(with: bank)
        self.numUsed = checkUsage(with: bank)
    }
    
    private func checkiOSApplication(with bank: SBPBankResponse) -> Bool {
        if let url = URL(string: bank.schema + "://") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
    
    private func checkUsage(with bank: SBPBankResponse) -> Int {
        let lastBanks = UserDefaults.standard.object(forKey: SBPRepository.LAST_USED_BANKS_KEY) as? [String] ?? []
        var num: Int = 0
        
        for item in lastBanks {
            if (item == bank.schema) { num += 1 }
        }
        
        return num
    }
    
    static func == (lhs: SBPBank, rhs: SBPBank) -> Bool {
        lhs.schema == rhs.schema && lhs.logoURL == rhs.logoURL && lhs.bankName == rhs.bankName
    }
}

