//
//  Storage.swift
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
import CoreData

class Storage {
    typealias Task = (NSManagedObjectContext) -> Swift.Void
    typealias RequestBlock = (_ request: NSFetchRequest<Event>) -> Void

    /// A context which is used to create database object from RAD payload.
    private (set) var createContext: NSManagedObjectContext?
    /// A context which is used to fetch events and send them to server.
    ///
    /// When certain conditions are met, events will be deleted.
    private (set) var deleteContext: NSManagedObjectContext?

    /// A context which is used to sync operations with session ids.
    private (set) var sessionContext: NSManagedObjectContext?

    /// The context which is associated with main queue.
    var mainQueueContext: NSManagedObjectContext {
        return container.viewContext
    }
    /// A background queue context.
    var backgroundQueueContext: NSManagedObjectContext? {
        return createContext
    }

    static let shared = Storage()

    private static let modelName = "RADDatabaseModel"
    private static let databaseName = "RADDatabase"

    private let container: NSPersistentContainer

    private var appTerminationObservation: Any?

    private init?() {
        guard let url = Bundle.framework.url(
            forResource: Storage.modelName, withExtension: "momd"
        ) else {
            print("Unable to find CoreData model.")
            return nil
        }
        let model = NSManagedObjectModel(contentsOf: url)
        let defaultModel = NSManagedObjectModel()
        container = NSPersistentContainer(
            name: Storage.databaseName,
            managedObjectModel: model ?? defaultModel)
    }

    func performBackgroundTask(_ block: @escaping Task) {
        container.performBackgroundTask(block)
    }

    /// Saves the given context. Must the called on context's queue.
    ///
    /// - Parameter context: The context to save.
    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Unable to save RAD context due to error: \(error).")
        }
    }

    /// If not loaded already, load persistentStores.
    func load() {
        guard container.persistentStoreCoordinator.persistentStores.count == 0
            else { return }

        container.loadPersistentStores { [weak self] (_, error) in
            if let error = error {
                print("Local database was not loaded due to error: \(error).")
            } else {
                self?.createContexts()
                let center = NotificationCenter.default
                self?.appTerminationObservation = center.addObserver(
                    forName: UIApplication.willTerminateNotification,
                    object: nil, queue: nil,
                    using: { [weak self] _ in
                        self?.saveContexts()
                })
            }
        }
    }

    /// Detroy current store and load a new one.
    /// The purpose of this function is to simplify the testing.
    func refreshDatabase() {
        container.persistentStoreCoordinator.performAndWait {
            deleteDatabase()
            load()
        }
    }

    // MARK: Private functionality

    private func saveContexts() {
        if let createContext = createContext {
            createContext.performAndWait { [weak self] in
                self?.save(context: createContext)
            }
        }

        if let deleteContext = deleteContext {
            deleteContext.performAndWait { [weak self] in
                self?.save(context: deleteContext)
            }
        }
    }

    private func createContexts() {
        mainQueueContext.automaticallyMergesChangesFromParent = true
        createContext = container.newBackgroundContext()
        createContext?.automaticallyMergesChangesFromParent = true
        deleteContext = container.newBackgroundContext()
        deleteContext?.automaticallyMergesChangesFromParent = true
        sessionContext = container.newBackgroundContext()
        sessionContext?.automaticallyMergesChangesFromParent = true
    }

    private func emptyPredicate(for relation: String) -> NSPredicate {
        return NSPredicate(
            format: "\(relation).@count == 0", argumentArray: nil)
    }

    /// Remove persistent stores and delete the database from url.
    /// This approach was chosen over destroyPersistentStore(at:ofType:options:)
    /// because it was failing to truncated the database.
    private func deleteDatabase() {
        do {
            try removeAllStores()
            try deleteDatabaseFiles()
        } catch {
            print("Unable to delete database due to error.")
        }
    }

    /// Removes all stores from coordinator. It should be just 1 SQLite store.
    ///
    /// - Throws: Error if store removal failed.
    private func removeAllStores() throws {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            try container.persistentStoreCoordinator.remove(store)
        }
    }

    /// Delete database
    ///
    /// - Throws: Error if file deletion failed.
    private func deleteDatabaseFiles() throws {
        let manager = FileManager.default
        let databaseUrl = NSPersistentContainer.defaultDirectoryURL()

        let filesInFolder = try manager.contentsOfDirectory(
            at: databaseUrl, includingPropertiesForKeys: nil, options: [])
        let databaseFiles = filesInFolder.filter({
            $0.lastPathComponent.hasPrefix(container.name)
        })

        try databaseFiles.forEach({ url in
            if manager.fileExists(atPath: url.path) {
                try manager.removeItem(at: url)
            }
        })
    }
}
