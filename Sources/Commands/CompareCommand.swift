//
//  CompareCommand.swift
//  
//
//  Created by Sorokin Igor on 25.10.2024.
//

import Foundation
import ArgumentParser
import PathKit

struct CompareCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "compare",
        abstract: "Checks the correctness of the generated headers."
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

    @Option(name: .long, help: "Prefix must be the same as for the generated headers")
    private var prefix: String = ""

    @Option(name: .long, help: "Path to directory with headers that needs to checked")
    private var headers: Path

    static var currentCompare: Compare?

    func run() {
        signal(SIGINT, handleCancellation)

        let compare = Compare()
        Self.currentCompare = compare
        
        do {
            try Compare().run(
                workspace: workspace,
                project: project,
                sdk: sdk,
                scheme: scheme,
                directory: directory,
                prefix: prefix,
                headers: headers
            )
            Logger.success("Headers are up-to-date")
        } catch {
            Logger.error(error.localizedDescription)
            Self.exit(withError: error)
        }
    }

}

private func handleCancellation(_ signal: Int32) {
    CompareCommand.currentCompare?.cancel()
    exit(signal)
}
