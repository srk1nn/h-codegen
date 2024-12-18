//
//  InternalWithPublic.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

@objc(HCPublicClass)
public final class PublicClass: NSObject { }

@objc(HCInternalWithPublicClass)
final class InternalWithPublicClass: NSObject {
    @objc let publicClass: PublicClass

    @objc
    init(publicClass: PublicClass) {
        self.publicClass = publicClass
    }
}
