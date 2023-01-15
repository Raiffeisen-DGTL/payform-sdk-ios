//
//  SBPBankResponse.swift
//
//
//  Created by Sergey Panov on 27.09.2022.
//

import Foundation

class SBPBankWrapper: Decodable {
    var version: String
    var dictionary: [SBPBankResponse]
}

class SBPBankResponse: Decodable {
    var bankName: String
    var logoURL: String
    var schema: String
    var packageName: String?
    
    enum CodingKeys: String, CodingKey {
        case bankName, logoURL, schema
        case packageName = "package_name"
    }
}
