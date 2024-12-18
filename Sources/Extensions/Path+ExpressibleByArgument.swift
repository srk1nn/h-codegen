//
//  Path+ExpressibleByArgument.swift
//
//
//  Created by Sorokin Igor on 13.10.2024.
//

import PathKit
import ArgumentParser

extension Path: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}
