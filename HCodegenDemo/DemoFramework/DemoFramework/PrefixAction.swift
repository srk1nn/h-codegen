//
//  PrefixAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// This example shows how works prefix action
//
// Prefix action below tells `h-codegen` to override prefix from CLI to `Ext` for generated file
//
// See ExtPrefixAction.h

// h-codegen:prefix:Ext

@objc
extension NSNumber {

    func internalExtensionMethod() { }

}
