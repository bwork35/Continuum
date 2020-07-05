//
//  DateExtension.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import Foundation

extension Date {
    func dateAsString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
