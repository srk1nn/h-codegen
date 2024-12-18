//
//  HeaderAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

// This example shows how works header action
//
// Since `h-codegen` doesn't know about Objective-C objects, you should use header action, to import (Objects.h) in generated file
//
// See HCHeaderAction.h

// h-codegen:header:Objects.h

@objc
final class HeaderAction: NSObject { }
