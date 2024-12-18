//
//  Codegen.swift
//
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import PathKit

struct Codegen {
    private let backupService = BackupService()
    private let objcHeaderGenerator = ObjcHeaderGenerator()
    private let objcHeaderParser = ObjcHeaderParser()
    private let swiftFileParser = SwiftFileParser()
    private let objcHeadersMapper = ObjcHeadersMapper()
    private let objcHeadersWriter = ObjcHeadersWriter()
    private let projectRewriter = ProjectRewriter()

    private let tmpDirectory = Path.current.absolute() + "hcodegen-codegen-tmp"

    func run(
        workspace: Path?,
        project: Path?,
        sdk: String,
        scheme: String?,
        directory: Path,
        destination: Path,
        prefix: String,
        generateOnly: Bool
    ) throws {

        do {
            let arguments = try validate(
                workspace: workspace,
                project: project,
                sdk: sdk,
                directory: directory,
                destination: destination,
                scheme: scheme,
                prefix: prefix,
                generateOnly: generateOnly
            )

            Logger.info("Preparing temporary directory")
            try prepare()

            Logger.info("Copying Swift files into temporary directory")
            try backupService.backupSwiftFiles(from: arguments.directory, to: tmpDirectory)

            Logger.info("Parsing Swift files")
            let swiftFiles = try swiftFileParser.parse(from: tmpDirectory)

            Logger.info("Generating -Swift.h")
            let generatedHeader = try objcHeaderGenerator.generate(
                projectType: arguments.projectType,
                sdk: arguments.sdk,
                scheme: arguments.scheme,
                codeDirectory: arguments.directory,
                workingDirectory: tmpDirectory
            )

            Logger.info("Parsing -Swift.h")
            let objcHeader = try objcHeaderParser.parse(file: generatedHeader)

            Logger.info("Mapping headers")
            let headers = try objcHeadersMapper.map(
                swiftFiles: swiftFiles,
                from: objcHeader,
                sdk: arguments.sdk,
                prefix: arguments.prefix
            )

            Logger.info("Writing headers")
            try objcHeadersWriter.write(headers: headers, to: destination)

            if !arguments.generateOnly {
                Logger.info("Updating xcodeproj")
                try projectRewriter.rewrite(projectType: arguments.projectType, destination: arguments.destination, sdk: arguments.sdk, target: arguments.sdk)
            }

            cleanup()
        } catch {
            cleanup()
            throw error
        }
    }

    func cancel() {
        cleanup()
    }

    private func validate(
        workspace: Path?,
        project: Path?,
        sdk: String,
        directory: Path,
        destination: Path,
        scheme: String?,
        prefix: String,
        generateOnly: Bool
    ) throws -> CodegenArguments {

        let projectType: ProjectType? = {
            if let workspace {
                return .workspace(workspace.absolute())
            } else if let project {
                return .project(project.absolute())
            }
            return nil
        }()

        guard let projectType else {
            throw CodegenError.missingRequiredOption("workspace or project")
        }

        switch projectType {
        case .workspace(let path) where path.extension != "xcworkspace":
            throw CodegenError.unexpectedFile(path.string, expected: "xcworkspace")
        case .project(let path) where path.extension != "xcodeproj":
            throw CodegenError.unexpectedFile(path.string, expected: "xcodeproj")
        default:
            break
        }

        if let scheme, scheme.isEmpty {
            throw CodegenError.missingRequiredOption("scheme")
        }

        if sdk.isEmpty {
            throw CodegenError.missingRequiredOption("sdk")
        }

        if !directory.exists || !directory.isDirectory {
            throw CodegenError.notDirectory(directory.string)
        }

        if destination.exists, !destination.isDirectory {
            throw CodegenError.notDirectory(destination.string)
        }

        return CodegenArguments(
            projectType: projectType,
            sdk: sdk,
            directory: directory.absolute(),
            destination: destination.absolute(),
            scheme: scheme ?? sdk,
            prefix: prefix,
            generateOnly: generateOnly
        )
    }

    private func prepare() throws {
        cleanup()
        try tmpDirectory.mkpath()
    }

    private func cleanup() {
        try? tmpDirectory.delete()
    }
}
