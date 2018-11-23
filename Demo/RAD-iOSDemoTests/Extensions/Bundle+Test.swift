//
//  Bundle+Test.swift
//  RAD-iOSDemoTests
//
//  Created by David Livadaru on 21/11/2018.
//  Copyright © 2018 NPR. All rights reserved.
//

import Foundation

extension Bundle {
    static let test = Bundle(for: BundlePrivateClass.self)
}

fileprivate class BundlePrivateClass {}
