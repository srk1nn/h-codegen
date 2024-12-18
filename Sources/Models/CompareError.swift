//
//  File.swift
//  
//
//  Created by Sorokin Igor on 25.10.2024.
//

import Foundation

enum CompareError: LocalizedError {
    case noDirectory(_ path: String)
    case checksumsNotEqual

    var errorDescription: String? {
        switch self {
        case .noDirectory(let path):
            "No directory at path \(path)"
        case .checksumsNotEqual:
            "Headers are outdated"
        }
    }
}
