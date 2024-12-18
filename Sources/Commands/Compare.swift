//
//  Compare.swift
//  
//
//  Created by Sorokin Igor on 25.10.2024.
//

import Foundation
import PathKit
import CryptoKit

struct Compare {
    private let codegen = Codegen()
    private let destination = Path.current.absolute() + "hcodegen-compare-tmp"

    func run(
        workspace: Path?,
        project: Path?,
        sdk: String,
        scheme: String?,
        directory: Path,
        prefix: String,
        headers: Path
    ) throws {
        let headers = headers.absolute()

        guard headers.exists else {
            throw CompareError.noDirectory(headers.string)
        }

        do {
            try prepare()

            Logger.info("Generating actual headers")
            try codegen.run(
                workspace: workspace,
                project: project,
                sdk: sdk,
                scheme: scheme,
                directory: directory,
                destination: destination,
                prefix: prefix,
                generateOnly: true
            )

            Logger.info("Calculating checksums")
            let source = try calculateChecksum(at: headers)
            let target = try calculateChecksum(at: destination)

            if source != target {
                throw CompareError.checksumsNotEqual
            }

            cleanup()
        } catch {
            cleanup()
            throw error
        }
    }

    func cancel() {
        codegen.cancel()
        cleanup()
    }

    private func calculateChecksum(at path: Path) throws -> Insecure.MD5.Digest {
        let files = try path.recursiveChildren()
            .filter { $0.isFile }
            .sorted(by: { $0.lastComponent > $1.lastComponent })

        var md5 = Insecure.MD5()

        try files.forEach {
            let data = try $0.read()
            md5.update(data: data)
        }

        return md5.finalize()
    }

    private func prepare() throws {
        cleanup()
        try destination.mkpath()
    }

    private func cleanup() {
        try? destination.delete()
    }
}
