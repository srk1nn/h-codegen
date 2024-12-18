//
//  ObjcHeaderGenerator.swift
//
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import SwiftCLI
import PathKit

/// An Objective-C header generator
///
/// Generation is done using standard Xcode tools.
/// A fake main function is inserted into one of the Swift files.
/// This makes the compiler think that he works with application code and generates the -Swift.h file with internal objects.
struct ObjcHeaderGenerator {

    func generate(
        projectType: ProjectType,
        sdk: String,
        scheme: String,
        codeDirectory: Path,
        workingDirectory: Path
    ) throws -> Path {

        let children = try workingDirectory.recursiveChildren().filter { $0.extension == "swift" }

        guard !children.isEmpty else {
            throw CodegenError.nothingToGenerate
        }

        try addFakeEntryPoint(into: children[0])
        let swiftFilesTxt = try createSwiftFilesTxt(in: workingDirectory, describing: children)

        let (projectKey, projectPath) = switch projectType {
        case .workspace(let path):
            (ScriptOptions.workspace, path)
        case .project(let path):
            (ScriptOptions.project, path)
        }

        let outCapture = CaptureStream()

        let logsCapture = LineStream {
            if $0.hasPrefix(ScriptPrefixes.log) {
                Logger.info($0.replacingOccurrences(of: ScriptPrefixes.log, with: ""))
            }
        }

        let task = Task(
            executable: ScriptOptions.executable,
            arguments: [
                ScriptOptions.bashCommand, Resources.emitObjcHeaderScript, "",
                projectKey, projectPath.string,
                ScriptOptions.scheme, scheme,
                ScriptOptions.target, sdk,
                ScriptOptions.codeDirectory, codeDirectory.string,
                ScriptOptions.swiftSDKFiles, swiftFilesTxt.string,
                ScriptOptions.tmpDirectory, workingDirectory.string
            ], 
            stdout: SplitStream(logsCapture, outCapture)
        )

        task.runSync()

        let outputFile = outCapture.readAll()
            .components(separatedBy: "\n")
            .first(where: { $0.hasPrefix(ScriptPrefixes.return) })?
            .replacingOccurrences(of: ScriptPrefixes.return, with: "")

        let generatedFile = Path(outputFile ?? "")

        guard generatedFile.isFile else {
            throw CodegenError.generation
        }

        return generatedFile
    }

    private func createSwiftFilesTxt(in workingDirectory: Path, describing files: [Path]) throws -> Path {
        let filePaths = files.map { $0.absolute().string }.joined(separator: "\n")
        let swiftFilesTxt = workingDirectory + Constants.swiftFilesTxt
        try swiftFilesTxt.write(filePaths, encoding: .utf8)
        return swiftFilesTxt
    }

    private func addFakeEntryPoint(into file: Path) throws {
        let originalSource = try file.read(.utf8)
        let editedSource = "\(Constants.fakeEntryPoint)\n\(originalSource)"
        try file.write(editedSource, encoding: .utf8)
    }

    private enum Constants {
        static let swiftFilesTxt = "swift-files.txt"
        static let fakeEntryPoint = "@main struct HCodegenMain { static func main() { } }"
    }

    private enum ScriptOptions {
        static let executable = "/bin/bash"
        static let bashCommand = "-c"
        static let workspace = "--workspace"
        static let project = "--project"
        static let scheme = "--scheme"
        static let target = "--target"
        static let codeDirectory = "--code-directory"
        static let swiftSDKFiles = "--swift-sdk-files"
        static let tmpDirectory = "--tmp-directory"
    }

    private enum ScriptPrefixes {
        static let log = "log:"
        static let `return` = "return:"
    }
}
