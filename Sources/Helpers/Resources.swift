//
//  Resources.swift
//  
//
//  Created by Sorokin Igor on 24.10.2024.
//

import Foundation

enum Resources {

    static let emitObjcHeaderScript: String = {
        guard let script = Bundle.module.path(forResource: "emit_objc_header", ofType: "sh") else {
            preconditionFailure("emit_objc_header.sh is missing")
        }
        return script
    }()

}
