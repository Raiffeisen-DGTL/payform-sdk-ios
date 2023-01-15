//
//  SBPInteractor.swift
//
//
//  Created by Sergey Panov on 28.09.2022.
//

import Foundation

class SBPRepository {
    
    static let instance = SBPRepository()
    
    static let LAST_USED_BANKS_KEY = "last_banks"
    
    private let sbpService = SBPBankService.instance
    
    private let userDefaults = UserDefaults.standard
    
    func getPreloadedBankApplications() -> [SBPBank] {
        let sbpBanks: [SBPBank] = sbpService.getPreloadedBankApplications()
        return sbpBanks
    }
    
    func loadBanks() async -> [SBPBank]? {
        let sbpBanks: [SBPBank]? = await sbpService.getBankApplications()
        return sbpBanks
    }
    
    func getLastBanks(_ num: Int) -> [String] {
        let allLastBanks: [String] = userDefaults.object(forKey: SBPRepository.LAST_USED_BANKS_KEY) as? [String] ?? []
        
        return Array(allLastBanks.prefixWithoutDuplicates(num))
    }
    
    func goToPayment(bank: SBPBank) {
        sbpService.goToPayment(bankSchema: bank.schema, bankName: bank.bankName)
        rememberUsingBank(bank: bank)
    }
    
    func gotToPaymentInDefaultBank() {
        sbpService.goToPayment(bankSchema: nil, bankName: nil)
    }
    
    private func rememberUsingBank(bank: SBPBank) {
        var lastBanks: [String] = userDefaults.object(forKey: SBPRepository.LAST_USED_BANKS_KEY) as? [String] ?? []
        
        lastBanks.insert(bank.schema, at: 0)
        
        userDefaults.set(lastBanks, forKey: SBPRepository.LAST_USED_BANKS_KEY)
    }
}
