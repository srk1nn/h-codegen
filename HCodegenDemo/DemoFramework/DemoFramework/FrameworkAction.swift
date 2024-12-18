//
//  FrameworkAction.swift
//  DemoFramework
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation
import MapKit

// Framework action below tells `h-codegen` to import framework (MapKit) in generated file

// h-codegen:framework:MapKit

@objc
final class FrameworkAction: NSObject, MKMapViewDelegate { }
