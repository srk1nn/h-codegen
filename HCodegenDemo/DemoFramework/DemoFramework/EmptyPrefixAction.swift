//
//  EmptyPrefixAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// This example shows how works prefix action
//
// Prefix action below tells `h-codegen` to remove any file prefix
//
// See EmptyPrefixAction.h

// h-codegen:prefix:

@objc
extension NSNumber {

    func anotherInternalExtensionMethod() { }

}
