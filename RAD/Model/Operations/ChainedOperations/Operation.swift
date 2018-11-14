//
//  Operation.swift
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

/// Basic operation which provides a simple interface to ease the work with
/// Foundation operation.
class Operation: Foundation.Operation {
    override var isExecuting: Bool {
        return _isExecuting
    }

    override var isFinished: Bool {
        return _isFinished
    }

    override var isReady: Bool {
        guard super.isReady else { return false }
        return _isReady || isCancelled
    }

    override var isAsynchronous: Bool {
        return true
    }

    /// The error which occured during the execution of operation.
    /// If the property is nil when completionBlock is called,
    /// then operation executed without errors.
    private (set) var finishError: Error?

    static let isExecutingKey = "isExecuting"
    static let isFinishedKey = "isFinished"
    static let isReadyKey = "isReady"

    private var _isExecuting: Bool = false
    private var _isFinished: Bool = false
    private var _isReady: Bool = true

    /// Updates *isExecuting* property by conforming to manual KVO compliance.
    ///
    /// - Parameter isExecuting: The new value of *isExecuting*.
    func updateExecution(_ isExecuting: Bool) {
        willChangeValue(forKey: Operation.isExecutingKey)
        _isExecuting = isExecuting
        didChangeValue(forKey: Operation.isExecutingKey)
    }

    /// Updates *isFinished* property by conforming to manual KVO compliance.
    ///
    /// - Parameter isFinished: The new value of *isFinished*.
    func updateFinished(_ isFinished: Bool) {
        willChangeValue(forKey: Operation.isFinishedKey)
        _isFinished = isFinished
        didChangeValue(forKey: Operation.isFinishedKey)
    }

    /// Updates *isReady* property by conforming to manual KVO compliance.
    ///
    /// - Parameter isReady: The new value of *isReady*.
    func updateReady(_ isReady: Bool) {
        willChangeValue(forKey: Operation.isReadyKey)
        _isReady = isReady
        didChangeValue(forKey: Operation.isReadyKey)
    }

    /// Subclasses should override this function and perform its work.
    ///
    /// Should not call super, but upon completion,
    /// it has the responsibility to call *finish(with:)* function.
    func execute() {
        assertionFailure("Execute function should be overriden.")
        finish()
    }

    override final func start() {
        guard !isCancelled else {
            finish()
            return
        }

        updateExecution(true)
        execute()
    }

    /// Finish the operation and retains the error on *finishError* property.
    ///
    /// - Parameter error: The error which occured during the execution of
    /// operation. If operation was successful, no parameter needs to be set,
    /// since *nil* is the default value.
    func finish(with error: Error? = nil) {
        finishError = error
        updateExecution(false)
        updateFinished(true)
    }
}
