//
//  PostError.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import Foundation

enum PostError: LocalizedError {
    
    case ckError(Error)
    case couldNotUnwrap
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get this post..."
        }
    }
}
