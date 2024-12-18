//
//  InternalObjects.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

@objc(HCInternalProtocol)
protocol InternalProtocol {
    func internalFunc()
}

@objc(HCInternalClass)
final class InternalClass: NSObject {
    static func classMethod() { }
}

extension InternalClass: InternalProtocol {
    func internalFunc() { }

    @objc(HCInternalNestedEnum)
    enum InternalNestedEnum: Int {
        case one
        case two
    }
}
