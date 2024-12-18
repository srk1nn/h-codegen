//
//  HCodegenCommand.swift
//  
//
//  Created by Sorokin Igor on 25.10.2024.
//

import Foundation
import ArgumentParser

@main
struct HCodegenCommand: ParsableCommand {
    static let _commandName: String = "h-codegen"

    static let configuration = CommandConfiguration(
        version: "0.1.0",
        subcommands: [CodegenCommand.self, CompareCommand.self],
        defaultSubcommand: CodegenCommand.self
    )
}
