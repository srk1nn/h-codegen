//
//  ObjcHeadersWriter.swift
//
//
//  Created by Sorokin Igor on 05.11.2024.
//

import Foundation
import PathKit

struct ObjcHeadersWriter {

    func write(headers: [HeaderDescription], to destination: Path) throws {
        if !destination.exists {
            try destination.mkpath()
        } else {
            try destination.children().forEach { try $0.delete() }
        }

        try headers.forEach { header in
            let file = destination + header.name
            try file.write(header.content, encoding: .utf8)
        }
    }

}
