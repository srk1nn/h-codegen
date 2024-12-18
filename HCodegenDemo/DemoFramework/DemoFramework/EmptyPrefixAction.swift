//
//  EmptyPrefixAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// Prefix action below tells `h-codegen` to remove any prefix

// h-codegen:prefix:

@objc
extension NSNumber {

    func anotherInternalExtensionMethod() { }

}
