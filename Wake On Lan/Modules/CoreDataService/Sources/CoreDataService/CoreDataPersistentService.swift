//
//  PersistentCoreDataService.swift
//  Wake on LAN
//
//  Created by Владислав Лисянский on 20.05.2020.
//  Copyright © 2020 Владислав Лисянский. All rights reserved.
//

import CocoaLumberjackSwift
import CoreData
import SharedProtocolsAndModels
import WOLResources

// MARK: - PersistentContainer

public enum PersistentContainer {
    public struct SQLite: PersistentContainerType {
        public static let store = NSSQLiteStoreType
        public static let persistentStoreDescriptions: [NSPersistentStoreDescription]? = {
            guard let persistentContainerURL = CoreDataConstants.persistentContainerURL else {
                fatalError("Persistent container URL is unavailable")
            }
            let description = NSPersistentStoreDescription(url: persistentContainerURL)
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: BundleConstants.iCloudContainerIdentifier
            )
            return [description]
        }()
    }

    public struct InMemory: PersistentContainerType {
        public static let store = NSInMemoryStoreType
        public static let persistentStoreDescriptions: [NSPersistentStoreDescription]? = {
            let description = NSPersistentStoreDescription()
            description.type = store
            return [description]
        }()
    }
}

// MARK: - PersistentContainerType

public protocol PersistentContainerType {
    static var store: String { get }
    static var persistentStoreDescriptions: [NSPersistentStoreDescription]? { get }
}

// MARK: - CoreDataService

public final class CoreDataService: CoreDataServiceProtocol {

    public private(set) lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(
            name: CoreDataConstants.persistentContainerName,
            managedObjectModel: managedObjectModel
        )
        if let persistentStoreDescriptions = persistentContainerType.persistentStoreDescriptions {
            container.persistentStoreDescriptions = persistentStoreDescriptions
        }

        return container
    }()

    public private(set) lazy var persistentStoreCoordinator = NSPersistentStoreCoordinator(
        managedObjectModel: managedObjectModel
    )

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle.module
        let modelURL = bundle.url(
            forResource: CoreDataConstants.persistentContainerName,
            withExtension: CoreDataConstants.persistentContainerExtension
        )
        let model = modelURL.flatMap { NSManagedObjectModel(contentsOf: $0) }
        guard let model else { fatalError("\(self) : Cannot load Core Data model") }

        return model
    }()

    private let persistentContainerType: PersistentContainerType.Type

    // MARK: - Init

    public init(persistentContainerType: PersistentContainerType.Type) {
        self.persistentContainerType = persistentContainerType
    }

}

// MARK: - ProvidesWeakSharedInstanceTrait

extension CoreDataService: ProvidesWeakSharedInstanceTrait {
    public static weak var weakSharedInstance: CoreDataService?

    public convenience init() {
        self.init(persistentContainerType: PersistentContainer.SQLite.self)
        createHostContainer()
    }
}
