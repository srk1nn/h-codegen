//
//  Logger.swift
//  
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import SwiftCLI

enum Logger {
    static func progress(_ message: String, progress: Float) {
        let progress = Int(progress * 100)
        let terminator = progress == 100 ? "\n" : "\r"
        Term.stdout.print("🔎 \(message): \(progress)%", terminator: terminator)
    }

    static func info(_ message: String) {
        Term.stdout.print("⚙️ \(message)")
    }

    static func success(_ message: String) {
        Term.stdout.print("✅ \(message)")
    }

    static func error(_ message: String) {
        Term.stdout.print("❌ \(message)")
    }
}
