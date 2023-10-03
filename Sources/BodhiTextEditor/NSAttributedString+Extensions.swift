//
//  File.swift
//  
//
//  Created by Tayler Moosa on 10/3/23.
//

import Foundation

extension NSAttributedString {
    func substring(with range: NSRange?) -> String? {
        // Check if the range is valid
        guard let range = range else { return nil }
        if range.location != NSNotFound && range.location + range.length <= self.length {
            return self.attributedSubstring(from: range).string
        }
        return nil
    }
}
