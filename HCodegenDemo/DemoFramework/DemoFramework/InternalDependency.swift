//
//  InternalDependency.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// This example shows how `h-codegen` generates Objective-C headers for internal Swift class, that uses another **internal** Swift objects
//
// See HCInternalDependency.h

@objcMembers
final class InternalDependency: NSObject, InternalProtocol {
    let dependency: InternalClass

    init(dependency: InternalClass) {
        self.dependency = dependency
    }

    func protocolInternalMethod() { }
}
