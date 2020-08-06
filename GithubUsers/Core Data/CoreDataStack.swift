//
//  CoreDataStack.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

class CoreDataStack {
	
	enum PersistenceType {
		case inMemory
		case onDisk
	}
	
	fileprivate(set) static var shared: NSPersistentContainer!
	static let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: CoreDataStack.self)])!
	static let documentName = "Model"
	
	/// The shared operation queue for all Core Data operations.
	static let queue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
	
	/// Asynchronously loads and sets the shared persistent container. If the persistent container has been set before, invoking this function again does nothing.
	class func initialize(persistenceType: PersistenceType, completion: @escaping (Result<NSPersistentContainer, Error>) -> Void) {
		if shared != nil {
			return
		}
		let persistentContainer = makeNew(persistenceType: persistenceType)
		persistentContainer.loadPersistentStores() { (_, error) in
			if let error = error {
				completion(.failure(error))
			} else {
				shared = persistentContainer
				persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
				completion(.success(persistentContainer))
			}
		}
	}
	
	class func makeNew(persistenceType: PersistenceType) -> NSPersistentContainer {
		let persistentContainer = NSPersistentContainer(name: documentName, managedObjectModel: model)
		if persistenceType == .inMemory,
			let description = persistentContainer.persistentStoreDescriptions.first {
			description.type = NSInMemoryStoreType
		}
		return persistentContainer
	}
	
}

