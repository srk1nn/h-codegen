//
//  CodegenError.swift
//  
//
//  Created by Sorokin Igor on 13.10.2024.
//

import Foundation

enum CodegenError: LocalizedError {
    case missingRequiredOption(_ name: String)
    case notDirectory(_ path: String)
    case unexpectedFile(_ path: String, expected: String)
    case unknownAction(_ action: String)
    case nothingToGenerate
    case generation
    case xcodeprojNotFound
    case pbxProjectNotFound

    var errorDescription: String? {
        switch self {
        case .missingRequiredOption(let name):
            "Missing required option: \(name)\nUse -h or --help for more details"
        case .notDirectory(let path):
            "Not directory at path \(path)"
        case .unexpectedFile(let path, let expected):
            "Unexpected file at path \(path), expected \(expected)"
        case .unknownAction(let action):
            "Unknown action \(action)"
        case .nothingToGenerate:
            "The source directory does not contain Swift files"
        case .generation:
            "An error occurred while generating the .h file. Please try to clear and rebuild the project"
        case .xcodeprojNotFound:
            ".xcodeproj not found"
        case .pbxProjectNotFound:
            "PBXProject not found"
        }
    }
}
