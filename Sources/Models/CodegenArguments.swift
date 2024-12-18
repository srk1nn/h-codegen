//
//  CodegenArguments.swift
//  
//
//  Created by Sorokin Igor on 16.10.2024.
//

import Foundation
import PathKit

struct CodegenArguments {
    let projectType: ProjectType
    let sdk: String
    let scheme: String
    let directory: Path
    let destination: Path
    let prefix: String
    let generateOnly: Bool

    init(
        projectType: ProjectType,
        sdk: String,
        directory: Path,
        destination: Path,
        scheme: String,
        prefix: String,
        generateOnly: Bool
    ) {
        self.projectType = projectType
        self.sdk = sdk
        self.directory = directory
        self.destination = destination
        self.scheme = scheme
        self.prefix = prefix
        self.generateOnly = generateOnly
    }
}
