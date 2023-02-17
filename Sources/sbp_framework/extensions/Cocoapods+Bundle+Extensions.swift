//
//  Bundle+Extensions.swift
//  sbp_framework
//
//  Created by Sergey Panov on 03.10.2022.
//

import Foundation

private class MyBundleFinder {}

extension Foundation.Bundle {
    
    static var sbpBundle: Bundle = {
        let bundleName = "sbp_framework"
        
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: MyBundleFinder.self).resourceURL,
            
            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        fatalError("Unable to find bundle named \(bundleName)")
    }()
}
