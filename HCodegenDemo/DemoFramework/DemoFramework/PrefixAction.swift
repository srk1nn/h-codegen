//
//  PrefixAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// Prefix action below tells `h-codegen` to override prefix from CLI to `Ext` in generated file

// h-codegen:prefix:Ext

@objc
extension NSNumber {

    func internalExtensionMethod() { }

}
