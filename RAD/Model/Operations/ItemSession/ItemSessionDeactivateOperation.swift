//
//  ItemSessionDeactivateOperation.swift
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

class ItemSessionDeactivateOperation: Operation {
    override func execute() {
        guard let context = Storage.shared?.createContext else {
            self.finish(with: InputError.inconsistentData)
            return
        }

        let fetchOperation = FetchOperation<ItemSession>(context: context)
        fetchOperation.input = NSPredicate(
            format: "isActive == true", argumentArray: nil)
        let deactivateOperation = ClosureInputOperation<[ItemSession]>(
            closure: { itemSessions in
                context.perform {
                    itemSessions.forEach({
                        $0.isActive = false
                    })
                }
        })
        fetchOperation.chainOperation(with: deactivateOperation)
        let saveOperation = SaveContextOperation(context: context)
        saveOperation.addDependency(deactivateOperation)
        saveOperation.completionBlock = {
            self.finish()
        }
        OperationQueue.background.addOperations(
            [fetchOperation, deactivateOperation, saveOperation],
            waitUntilFinished: false)
    }
}
