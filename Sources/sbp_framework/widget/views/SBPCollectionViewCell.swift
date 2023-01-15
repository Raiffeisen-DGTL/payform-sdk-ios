//
//  SBPCollectionViewCell.swift
//  sbp_framework
//
//  Created by Sergey Panov on 30.09.2022.
//

import UIKit

class SBPCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String = "BankCell"
    
    private var downloadTask: URLSessionDataTask?

    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 16.0
            imageView.layer.masksToBounds = true
        }
    }
    @IBOutlet private weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel.text = ""
        imageView.image = nil
        downloadTask?.cancel()
    }
    
    func fillContent(with item: SBPBankViewItem) {
        textLabel.text = item.bank.bankName
        downloadTask = imageView.download(from: item.bank.logoURL)
    }

}
