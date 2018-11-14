//
//  WeakReferenceContainer.swift
//  RAD
//
//  Copyright 2018 NPR
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//  this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import Foundation

struct WeakReferenceContainer<Type> {
    private var container: [WeakReference<Type>] = []

    init() {}

    mutating func append(_ value: Type) {
        container.append(WeakReference<Type>(value: value))
    }

    mutating func remove(_ value: Type) {
        let weakReference = WeakReference<Type>(value: value)
        guard let index = container.index(where: { reference -> Bool in
            reference == weakReference
        }) else { return }
        container.remove(at: index)
    }

    mutating func forEach(_ closure: (Type?) -> Void) {
        let availableObjects = container.filter({ $0.value != nil })
        container = availableObjects
        container.forEach({
            closure($0.value)
        })
    }
}
