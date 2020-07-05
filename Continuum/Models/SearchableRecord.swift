//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Bryan Workman on 7/1/20.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool 
}
