//
//  PublicDependency.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// This example shows how `h-codegen` generates Objective-C headers for internal Swift class, that uses another **public** Swift objects
//
// See HCPublicDependency.h

@objc(HCPublicClass)
public final class PublicClass: NSObject { }

@objc(HCPublicProtocol)
public protocol PublicProtocol {
    func protocolPublicMethod()
}

@objc(HCPublicDependency)
final class PublicDependency: NSObject, PublicProtocol {
    @objc let publicClass: PublicClass

    @objc
    init(publicClass: PublicClass) {
        self.publicClass = publicClass
    }

    func protocolPublicMethod() { }
}
