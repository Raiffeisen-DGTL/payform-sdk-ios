//
//  SBPHeaderReusableView.swift
//  sbp_framework
//
//  Created by Sergey Panov on 29.09.2022.
//

import Foundation
import UIKit

class SBPHeaderReusableView: UICollectionReusableView {
    
    static let identifier = "SectionHeader"
    
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    func configureView() {
        addSubview(headerTitleLabel)
        NSLayoutConstraint.activate([
            headerTitleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            headerTitleLabel.topAnchor.constraint(equalTo: topAnchor),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fillTitle(title: String) {
        headerTitleLabel.text = title
    }
    
}
