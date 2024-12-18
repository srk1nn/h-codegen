//
//  CodegenCommand.swift
//
//
//  Created by Sorokin Igor on 17.10.2024.
//

import Foundation
import PathKit
import ArgumentParser

struct CodegenCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "codegen",
        abstract: "Generates Objective-C headers from Swift files."
    )

    @Option(name: .long, help: "Path to xcworkspace. Specify the path to xcworkspace or to xcodeproj, but not both")
    private var workspace: Path?

    @Option(name: .long, help: "Path to xcodeproj. Specify the path to xcworkspace or to xcodeproj, but not both")
    private var project: Path?

    @Option(name: .long, help: "SDK name")
    private var sdk: String

    @Option(name: .long, help: "SDK build scheme. By default takes from sdk")
    private var scheme: String?

    @Option(name: .long, help: "Path to code directory")
    private var directory: Path

    @Option(name: .long, help: "Destination directory where to generate files")
    private var destination: Path

    @Option(name: .long, help: "Prefix for generated headers")
    private var prefix: String = ""

    @Flag(name: .long, help: "Skip adding generated files to xcodeproj")
    private var genOnly = false

    static var currentCodegen: Codegen?

    func run() {
        signal(SIGINT, handleCancellation)

        let hcodegen = Codegen()
        Self.currentCodegen = hcodegen

        do {
            try hcodegen.run(
                workspace: workspace,
                project: project,
                sdk: sdk,
                scheme: scheme,
                directory: directory,
                destination: destination,
                prefix: prefix,
                generateOnly: genOnly
            )
            Logger.success("Done")
        } catch {
            Logger.error(error.localizedDescription)
            Self.exit(withError: error)
        }
    }
}

private func handleCancellation(_ signal: Int32) {
    CodegenCommand.currentCodegen?.cancel()
    exit(signal)
}
