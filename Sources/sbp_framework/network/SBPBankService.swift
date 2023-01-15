//
//  SBPBankService.swift
//
//
//  Created by Sergey Panov on 27.09.2022.
//

import Foundation
import UIKit

protocol SBPBankServiceProtocol {
    func getPreloadedBankApplications() throws -> [SBPBank]
    
    func getBankApplications() async -> [SBPBank]?
    
    func goToPayment(bankSchema: String?, bankName: String?)
}

final class SBPBankService: SBPBankServiceProtocol {
    
    static let url = "https://qr.nspk.ru/proxyapp/c2bmembers.json"
    static let fileName = "sbp_banks"
    static let storeLink = "itms-apps://search.itunes.apple.com/search?media=software&term="
    var deepLinkUrl: String?
    
    static let instance = SBPBankService()
    
    func getPreloadedBankApplications() -> [SBPBank] {
        if let url = Bundle.sbpBundle.url(forResource: SBPBankService.fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(SBPBankWrapper.self, from: data)
                return jsonData.dictionary.map { SBPBank(bank: $0) }
            } catch let error {
                SBPRouter.instance.gotError(error: error)
            }
        }
        return []
    }
    
    func getBankApplications() async -> [SBPBank]? {
        do {
            let url = URL(string: SBPBankService.url)!
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(SBPBankWrapper.self, from: data)
            return jsonData.dictionary.map { SBPBank(bank: $0) }
        } catch let error {
            SBPRouter.instance.gotError(error: error)
            return nil
        }
    }
    
    func goToPayment(bankSchema: String?, bankName: String?) {
        guard let deepLinkUrl = deepLinkUrl else {
            return SBPRouter.instance.gotError(error: SBPError.notCorrectUrl("deeplink not initialized in SBPBankService"))
        }
        
        var formattedURL: URL?
        
        if let bankSchema = bankSchema {
            formattedURL = URL(string: deepLinkUrl.replacingOccurrences(of: "https", with: bankSchema))
        } else {
            formattedURL = URL(string: deepLinkUrl)
        }
        
        guard let formattedURL = formattedURL else {
            return SBPRouter.instance.gotError(error: SBPError.notCorrectUrl("url not correct: \(deepLinkUrl)"))
        }
        
        
        if UIApplication.shared.canOpenURL(formattedURL) {
            UIApplication.shared.open(formattedURL, options: [:], completionHandler: nil)
            SBPRouter.instance.selectedBankApplicationScheme(bankSchema, isInstalled: true)
        } else {
            if let bankSchema = bankSchema, let bankName = bankName?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: SBPBankService.storeLink+bankName) {
                UIApplication.shared.open(url)
                SBPRouter.instance.selectedBankApplicationScheme(bankSchema, isInstalled: false)
            } else {
                SBPRouter.instance.gotError(error: SBPError.notCorrectUrl("error redirecting to app store: \(String(describing: bankSchema))"))
            }
        }
    }
}
