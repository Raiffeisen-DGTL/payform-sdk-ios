//
//  SBPRouter.swift
//  sbp_framework
//
//  Created by Sergey Panov on 05.10.2022.
//

import Foundation

class SBPRouter {
    
    static let instance = SBPRouter()
    
    var callback: ((SBPResult) -> Void)?
    
    func selectedBankApplicationScheme(_ scheme: String?, isInstalled: Bool = false) {
        switch (scheme, isInstalled) {
        case (nil, _):
            callback?(.redirectToDefaultBank)
        case (scheme, true):
            callback?(.redirectToBank(schema: scheme!))
        case (scheme, false):
            callback?(.redirectToDownloadBank(schema: scheme!))
        default:
            fatalError("select bank completion get default case")
        }
    }
    
    func dialogDissmissed() {
        callback?(.dialogDismissed)
    }
    
    func gotError(error: Error) {
        callback?(.redirectToBankFailed(error: error))
    }
}
