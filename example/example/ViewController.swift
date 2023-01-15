//
//  ViewController.swift
//  example
//
//  Created by Sergey Panov on 06.10.2022.
//

import UIKit
import sbp_framework

class ViewController: UIViewController {
    
    static let linkUrl = "https://qr.nspk.ru/AD100004BAL7227F9BNP6KNE007J9B3K?type=02&bank=100000000007&sum=1&cur=RUB&crc=AB75"
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var sbpButton: UIButton! {
        didSet {
            sbpButton.setTitle("Pay with SBP", for: .normal)
        }
    }
    
    private var sbpModule: SBPRedirectModule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showSBPPopup(_ sender: Any) {
        let link: String = (linkTextField.text ?? "").isEmpty ? ViewController.linkUrl : linkTextField.text!
        
        sbpModule = SBPRedirectModule(link: link) { [weak self] result in
            switch result {
            case let .redirectToBank(scheme):
                print("redirected to bank: \(scheme)")
                self?.sbpModule?.dismiss()
            case let .redirectToDownloadBank(scheme):
                print("redirected to App Store to download bank: \(scheme)")
            case let .redirectToBankFailed(error):
                print(error)
            case .redirectToDefaultBank:
                print("redirect to default bank")
                self?.sbpModule?.dismiss()
            case .dialogDismissed:
                print("dialog dissmissed")
            @unknown default:
                fatalError()
            }
        }
        
        sbpModule?.show(on: self)
    }
}

