//
//  InternalObjects.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// This example shows how `h-codegen` generates Objective-C headers for internal Swift objects
//
// See HCInternalObjects.h

@objc(HCInternalProtocol)
protocol InternalProtocol {
    func protocolInternalMethod()
}

@objc(HCInternalClass)
final class InternalClass: NSObject {
    @objc static func classInternalMethod() { }
}

extension InternalClass: InternalProtocol {
    func protocolInternalMethod() { }

    @objc(HCInternalNestedEnum)
    enum InternalNestedEnum: Int {
        case one
        case two
    }
}
