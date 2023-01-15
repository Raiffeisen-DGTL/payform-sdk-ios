//
//  localization.swift
//  sbp_framework
//
//  Created by Sergey Panov on 03.10.2022.
//

import Foundation

extension String {
    func localized(withComment comment: String = "") -> String {
        return Bundle.sbpBundle.localizedString(forKey: self, value: "**\(self)**", table: nil)
    }
}

public enum Localization {
    public static let widgetTitle = "widget_title".localized()
    public static let searchPlaceholder = "search_placeholder".localized()
    public static let searchCancel = "search_cancel".localized()
    public static let defaultButtonText = "default_button_text".localized()
    public static let searchHelpButtonText = "search_help_button_text".localized()
    public static let recentBanks = "recent_banks".localized()
    public static let allBanks = "all_banks".localized()
}
