//
//  SBPCollectionView.swift
//  sbp_framework
//
//  Created by Sergey Panov on 29.09.2022.
//

import Foundation
import UIKit

final class SBPCollectionViewManager: NSObject {
    
    private let sbpRepository = SBPRepository.instance
    
    private let collectionView: UICollectionView
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, SBPBankViewItem>!
    
    private var allBanks: [SBPBankViewItem] = [] 
    
    private var banks: [SBPBankViewItem] = []
    
    private var lastBanks: [SBPBankViewItem] = []
    
    private var filteredBanks: [SBPBankViewItem] = []
    
    private var isHeadersHidden = true
    
    enum Section: Int, CaseIterable {
        case recent
        case all
    }
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        allBanks = sbpRepository.getPreloadedBankApplications().map { SBPBankViewItem(with: $0) }
        
        updateInstalledBanks()
        lastBanks = sbpRepository.getLastBanks(UIDevice.current.userInterfaceIdiom == .pad ? 5 : 4).compactMap { schema in
            let bank = banks.first(where: { $0.bank.schema == schema })?.bank
            return bank != nil ? SBPBankViewItem(with: bank!) : nil
        }
        banks.sort{ $0.bank.numUsed > $1.bank.numUsed }
        
        isHeadersHidden = lastBanks.isEmpty ? true : false
        
        dataSource = configureDataSource()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        loadBanks()
        applySnapshot(isSearching: false)
        
        collectionView.collectionViewLayout = createLayout()
        
        let nib = UINib(nibName: "SBPCollectionViewCell", bundle: Bundle.sbpBundle)
        collectionView.register(nib, forCellWithReuseIdentifier: SBPCollectionViewCell.identifier)
        
        collectionView.register(
            SBPHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SBPHeaderReusableView.identifier
        )
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<Section, SBPBankViewItem> {
        
        let dataSource = UICollectionViewDiffableDataSource<Section, SBPBankViewItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SBPCollectionViewCell.identifier, for: indexPath) as! SBPCollectionViewCell
            cell.fillContent(with: item)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader, !self.isHeadersHidden else {
                return SBPHeaderReusableView()
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SBPHeaderReusableView.identifier,
                for: indexPath) as? SBPHeaderReusableView
            let section = self.dataSource.snapshot()
                .sectionIdentifiers[indexPath.section]
            view?.fillTitle(title: section == .recent ? Localization.recentBanks : Localization.allBanks)
            
            return view
        }
        
        return dataSource
    }
    
    private func applySnapshot(isSearching: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SBPBankViewItem>()
        if(!isSearching) {
            snapshot.appendSections([.recent])
            snapshot.appendItems(lastBanks, toSection: .recent)
            snapshot.appendSections([.all])
            snapshot.appendItems(banks, toSection: .all)
        } else {
            snapshot.appendSections([.all])
            snapshot.appendItems(filteredBanks, toSection: .all)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = {(sectionIndex: Int, layout: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: UIDevice.current.userInterfaceIdiom == .pad ? 5 : 4)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: self.isHeadersHidden ? 0 : 36, trailing: 10)
            
            if(!self.isHeadersHidden) {
                let headerFooterSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(20)
                )
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func searchBanks(withTerm term: String) {
        let lowercasedTerm = term.lowercased()
        
        if (term == "") {
            isHeadersHidden = lastBanks.isEmpty ? true : false
        } else {
            filteredBanks = allBanks.filter { $0.bank.bankName.lowercased().contains(lowercasedTerm) }
            isHeadersHidden = true
        }
        
        applySnapshot(isSearching: term != "")
    }
    
   private func loadBanks() {
        Task { [weak self] in
            let updatedBanks = await self?.sbpRepository.loadBanks()
            
            if let banks = updatedBanks {
                await self?.updateBanks(
                    banks
                    .map { SBPBankViewItem(with: $0) }
                    .sorted(by: { $0.bank.numUsed > $1.bank.numUsed })
                )
            } else {
                return
            }
        }
    }
    
    private func updateInstalledBanks() {
        let installedBanks = self.allBanks.filter { $0.bank.isInstalled == true }
        self.banks = installedBanks.isEmpty ? allBanks : installedBanks
    }
    
    @MainActor
    private func updateBanks(_ newBanks: [SBPBankViewItem]) {
        
        self.allBanks.updateDifference(with: newBanks, by: { $0.bank == $1.bank })
        
        let newInstalledBanks = self.allBanks.filter { $0.bank.isInstalled == true }
        self.banks.updateDifference(with: newInstalledBanks.isEmpty ? self.allBanks : newInstalledBanks, by: { $0.bank == $1.bank })
        
        self.applySnapshot(isSearching: false)
    }
}

extension SBPCollectionViewManager: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        sbpRepository.goToPayment(bank: item.bank)
    }
    
}

