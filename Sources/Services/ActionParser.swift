//
//  ActionParser.swift
//
//
//  Created by Sorokin Igor on 24.10.2024.
//

import Foundation

struct ActionParser {

    func parseActions(from comment: String) throws -> [CodegenAction] {
        try comment.matches(regex: .action).map {
            let components = $0.components(separatedBy: Constants.separator)

            guard !components.isEmpty else {
                throw CodegenError.unknownAction($0)
            }

            let action = components[0]
            let params = Array(components.dropFirst())

            switch action {
            case Constants.header where params.count == 1:
                return .header(params[0])
            case Constants.framework where params.count == 1:
                return .framework(params[0])
            case Constants.prefix where params.count <= 1:
                return .prefix(params.first ?? "")
            default:
                throw CodegenError.unknownAction(action)
            }
        }
    }

    private enum Constants {
        static let separator = ":"
        static let header = "header"
        static let framework = "framework"
        static let prefix = "prefix"
    }
}
