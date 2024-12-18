//
//  FrameworkAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation
import MapKit

// This example shows how works framework action
//
// Since `h-codegen` doesn't know about Objective-C objects, you should use header action, to import (Objects.h) in generated file
//
// See HCFrameworkAction.h

// h-codegen:framework:MapKit

@objc
final class FrameworkAction: NSObject, MKMapViewDelegate { }
