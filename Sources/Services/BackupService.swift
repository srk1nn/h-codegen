//
//  BackupService.swift
//
//
//  Created by Sorokin Igor on 13.10.2024.
//

import Foundation
import PathKit

struct BackupService {

    /// Recursively copies all Swift files, 
    /// preserving the hierarchy to avoid overwriting.
    func backupSwiftFiles(from fromDirectory: Path, to toDirectory: Path) throws {
        for child in try fromDirectory.children() {
            if child.extension == "swift" {
                try toDirectory.mkpath()
                try child.copy(toDirectory + child.lastComponent)
            } else if child.isDirectory {
                let subDirectory = toDirectory + child.lastComponent
                try backupSwiftFiles(from: child, to: subDirectory)
            }
        }
    }

}
