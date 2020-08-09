//
//  CoreDataService_AllRecords_Purge.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.AllRecords {
	
	/// Using batch deletes, deletes all records for all entities in the persistent store.
	class Purge: Operation<Any?, Error> {
		
		let persistentContainer: NSPersistentContainer
		
		/// Creates a new instance.
		/// - Parameters:
		///		- context: The worker context that will execute the batch delete requests.
		init(persistentContainer: NSPersistentContainer, completion: OperationCompletionBlock?) {
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completion)
		}
		
		override func main() {
			do {
				let context = persistentContainer.newBackgroundContext()
				try Purge.execute(context: context)
				result = .success(nil)
			} catch {
				result = .failure(error)
			}
		}
		
		class func execute(context: NSManagedObjectContext) throws {
			let requests = [
				NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserListItem.self)),
				NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserProfile.self)),
				NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Image.self))
			]
			for request in requests {
				var executeError: Error?
				context.performAndWait {
					do {
						let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
						try context.execute(deleteRequest)
					} catch {
						executeError = error
					}
				}
				if let error = executeError {
					throw error
				}
			}
		}
		
	}
	
}
