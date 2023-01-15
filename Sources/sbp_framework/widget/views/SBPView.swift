//
//  SBPView.swift
//
//
//  Created by Sergey Panov on 28.09.2022.
//
import Foundation
import UIKit

class SBPView: UILoadableView {

    @IBOutlet private var bottomView: UIStackView!
    @IBOutlet private var titleLabel: UILabel! {
        didSet{
            titleLabel.text = Localization.widgetTitle
        }
    }
    @IBOutlet private var exitButton: UIButton! {
        didSet {
            exitButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet private var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = Localization.searchPlaceholder
        }
    }
    @IBOutlet private var searchHelpLabel: UILabel! {
        didSet{
            searchHelpLabel.text = Localization.searchHelpButtonText
        }
    }
    @IBOutlet private var byDefaultButton: UIButton! {
        didSet{
            byDefaultButton.setTitle(Localization.defaultButtonText, for: .normal)
        }
    }
    @IBOutlet private var sbpCollectionView: UICollectionView!

    override var bundle: Bundle {
        return Bundle.sbpBundle
    }
    
    private var sbpCollectionViewManager: SBPCollectionViewManager?
    
    var closeAction: (() -> Void)?
    
    func configureView() {
        sbpCollectionViewManager = SBPCollectionViewManager(collectionView: sbpCollectionView)
        searchBar.delegate = self
    }
    
    @IBAction private func onCloseButtonPressed() {
        closeAction?()
    }
    
    @IBAction private func onDefaultBankButtonPressed() {
        SBPRepository.instance.gotToPaymentInDefaultBank()
    }
    
}

extension SBPView: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setValue(Localization.searchCancel, forKey: "cancelButtonText")
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sbpCollectionViewManager?.searchBanks(withTerm: searchText)
        searchHelpLabel.isHidden = searchText.isEmpty
    }
}
