//
//  SBPRedirectModule.swift
//  raiffeisenSDK
//
//  Created by Sergey Panov on 28.09.2022.
//

import Foundation
import UIKit

public enum SBPResult {

    case redirectToBank(schema: String)

    case redirectToDownloadBank(schema: String)
    
    case redirectToDefaultBank
    
    case dialogDismissed
    
    case redirectToBankFailed(error: Error)
    
}

public enum SBPError: Error {
    case cantFindAppInStore(message: String, bankSchema: String)
    case notCorrectUrl(String)
}

public class SBPRedirectModule {
    public typealias CompletionHandler = (SBPResult) -> ()
    
    private var completion: CompletionHandler?
    private weak var sbpViewController: SBPViewController?
    
    public init(link: String, completion: @escaping CompletionHandler) {
        self.completion = completion
        
        SBPBankService.instance.deepLinkUrl = link
        SBPRouter.instance.callback = callback
        
    }
    
    public func show(on viewController: UIViewController) {
        let vc = SBPViewController()
        vc.modalPresentationStyle = .overCurrentContext
        viewController.present(vc, animated: false)
        
        sbpViewController = vc
    }
    
    public func dismiss() {
        sbpViewController?.animateDismissView()
        sbpViewController = nil
        completion = nil
    }
    
    private func callback(_ result: SBPResult) {
        completion?(result)
    }
}
