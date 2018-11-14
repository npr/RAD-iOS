//
//  UnlockObjectsOperation.swift
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

class UnlockObjectsOperation: Operation {
    override func execute() {
        guard let context = Storage.shared?.sessionContext else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        let predicate = NSPredicate(
            format: "isLocked == true", argumentArray: nil)

        let fetchIds = FetchOperation<ItemSessionID>(context: context)
        fetchIds.input = predicate
        let unlockIds = LockSessionOperation(lock: false, context: context)
        fetchIds.chainOperation(with: unlockIds)

        let fetchRad = FetchOperation<Rad>(context: context)
        fetchRad.input = predicate
        let unlockRad = LockRadOperation(lock: false, context: context)
        fetchRad.chainOperation(with: unlockRad)

        let saveOperation = SaveContextOperation(context: context)
        saveOperation.completionBlock = {
            self.finish()
        }
        saveOperation.addDependency(unlockIds)
        saveOperation.addDependency(unlockRad)

        OperationQueue.background.addOperations(
            [fetchIds, unlockIds, fetchRad, unlockRad, saveOperation],
            waitUntilFinished: false)
    }
}
