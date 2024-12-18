//
//  CodegenAction.swift
//  
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation

enum CodegenAction {
    case header(String)
    case framework(String)
    case prefix(String)

    var overridePrefix: String? {
        switch self {
        case .prefix(let prefix):
            prefix
        default:
            nil
        }
    }
}
