//
//  FetchOperation.swift
//  RAD
//
//  Created by David Livadaru on 17/08/2018.
//  Copyright © 2018 National Public Radio. All rights reserved.
//

import Foundation
import CoreData

/// Fetch operations are ready to be executed by default.
/// Chaining it with Output<NSPredicate> will wait until NSPredicate is set.
class FetchOperation<T: NSManagedObject>:
ChainOperation<NSPredicate, [T]> {
    typealias ConfigureRequest<T: NSManagedObject> =
        (_ request: NSFetchRequest<T>) -> Void
    private let context: NSManagedObjectContext
    private let configureClosure: ConfigureRequest<T>?

    /// Create a fetch operation.
    ///
    /// - Parameters:
    ///   - context: The context which is used to fetch objects from.
    ///   - configureClosure: Closure which may be used to customize
    /// the fetch request (e.g.: setting sort descriptors or a fetch limit).
    init(
        context: NSManagedObjectContext,
        configureClosure: ConfigureRequest<T>? = nil
    ) {
        self.context = context
        self.configureClosure = configureClosure

        super.init()

        updateReady(true)
    }

    override func execute() {
        guard let entityName = T.entity().name else {
            finish(with: FetchError.entityNotFound)
            return
        }

        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = input
        configureClosure?(request)

        context.perform {
            do {
                let result: NSAsynchronousFetchResult<T>? =
                    try self.context.execute(request)
                self.finish(with: result?.finalResult ?? [])
            } catch {
                self.finish(with: error)
            }
        }
    }
}
