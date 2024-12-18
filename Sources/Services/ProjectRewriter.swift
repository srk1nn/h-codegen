//
//  ProjectRewriter.swift
//
//
//  Created by Sorokin Igor on 17.10.2024.
//

import Foundation
import XcodeProj
import PathKit

struct ProjectRewriter {
    private typealias FilePathTuple = (file: PBXFileElement, path: Path)

    func rewrite(projectType: ProjectType, destination: Path, sdk: String, target: String) throws {
        switch projectType {
        case .workspace(let path):
            let xcworkspace = try XCWorkspace(path: path)
            let xcodeproj = try findXcodeproj(in: xcworkspace.data.children, sourceRoot: path.parent(), sdk: sdk)

            guard let xcodeproj else {
                throw CodegenError.xcodeprojNotFound
            }

            try rewrite(xcodeproj: xcodeproj.proj, path: xcodeproj.path, destination: destination, sdk: sdk, target: target)
        case .project(let path):
            let xcodeproj = try XcodeProj(path: path)
            try rewrite(xcodeproj: xcodeproj, path: path, destination: destination, sdk: sdk, target: target)
        }
    }

    private func rewrite(xcodeproj: XcodeProj, path: Path, destination: Path, sdk: String, target: String) throws {
        guard 
            let pbxProject = xcodeproj.pbxproj.projects.first(where: { pbxProject in
                pbxProject.targets.contains(where: { $0.name == sdk })
            })
        else {
            throw CodegenError.pbxProjectNotFound
        }

        let existingPBXGroup = try findPBXGroup(in: pbxProject.mainGroup.children, sourceRoot: path.parent(), destination: destination)

        let pbxGroup: PBXGroup
        if let existingPBXGroup {
            pbxGroup = existingPBXGroup
        } else {
            pbxGroup = try pbxProject.mainGroup.addGroup(named: destination.lastComponent)[0]
            pbxGroup.sourceTree = .absolute
            pbxGroup.path = destination.string
            pbxGroup.name = destination.lastComponent
        }

        let (insert, delete) = try calculateDiff(pbxGroup, sourceRoot: path.parent(), destination: destination)

        pbxGroup.children.removeAll(where: { 
            delete.contains($0)
        })

        let insertReferences = try insert.map {
            try pbxGroup.addFile(at: $0, sourceRoot: path.parent())
        }

        if let pbxTarget = pbxProject.targets.first(where: { $0.name == target }), let buildPhase = pbxTarget.buildPhases.first(where: { $0.buildPhase == .headers }) {
            buildPhase.files?.removeAll(where: { buildFile in
                buildFile.file.map { delete.contains($0) } ?? false
            })

            try insertReferences.forEach {
                _ = try buildPhase.add(file: $0)
            }
        }

        pbxGroup.children.sort(by: {
            guard
                let first = $0.name ?? $0.path,
                let second = $1.name ?? $1.path
            else {
                return false
            }
            return first.compare(second) == .orderedAscending
        })

        try xcodeproj.write(path: path)
    }

    private func calculateDiff(_ pbxGroup: PBXGroup, sourceRoot: Path, destination: Path) throws -> (insert: [Path], delete: [PBXFileElement]) {
        let destinations = try destination.children()

        let filePathTuples: [FilePathTuple] = try pbxGroup.children.compactMap { file in
            guard let path = try file.fullPath(sourceRoot: sourceRoot) else {
                return nil
            }
            return (file, path)
        }

        let delete = filePathTuples
            .filter { !destinations.contains($0.path) }
            .map { $0.file }

        let insert = destinations.filter { path in
            !filePathTuples.contains(where: { $0.path == path })
        }

        return (insert, delete)
    }

    private func findXcodeproj(in elements: [XCWorkspaceDataElement], sourceRoot: Path, sdk: String) throws -> (path: Path, proj: XcodeProj)? {
        for children in elements {
            switch children {
            case .file(let file):
                if
                    let path = fullPath(for: file.location, sourceRoot: sourceRoot),
                    let xcodeproj = try? XcodeProj(path: path),
                    xcodeproj.pbxproj.nativeTargets.contains(where: { $0.name == sdk }) {

                    return (path, xcodeproj)
                }
            case .group(let group):
                if let args = try findXcodeproj(in: group.children, sourceRoot: sourceRoot + group.location.path, sdk: sdk) {
                    return args
                }
            }
        }

        return nil
    }

    private func findPBXGroup(in elements: [PBXFileElement], sourceRoot: Path, destination: Path) throws -> PBXGroup? {
        for element in elements {
            guard let group = element as? PBXGroup else {
                continue
            }
            
            if try group.fullPath(sourceRoot: sourceRoot.string) == destination.string {
                return group
            } else if let childrenGroup = try findPBXGroup(in: group.children, sourceRoot: sourceRoot, destination: destination) {
                return childrenGroup
            }
        }
        return nil
    }

    private func fullPath(for location: XCWorkspaceDataElementLocationType, sourceRoot: Path) -> Path? {
        switch location {
        case .absolute(let path):
            return Path(path)
        case .container(let path):
            return sourceRoot + path
        case .developer(let path):
            return "/Applications/Xcode.app/Contents/Developer" + path
        case .group(let path):
            return sourceRoot + path
        default:
            return nil
        }
    }
}
