//
//  CoreDataService_Users_Save.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.Users {
	
	/// Using a batch insert, saves user list items to the persistent store. If successful, the result holds `nil`. If failed, the result holds an error.
	class Save: Operation<Any?, Error> {
		
		let objects: [[String : Any]]
		let persistentContainer: NSPersistentContainer
		
		/// Creates a new instance of a save operation.
		/// - Parameters:
		///		- objects: An array of `UserListItem` dictionary objects to be inserted by the batch request.
		///		- persistentContainer: The `NSPersistentContainer` that will create the background `NSManagedObjectContext` for this operation.
		///		- completion: Executed when the operation finishes.
		init(objects: [[String : Any]], persistentContainer: NSPersistentContainer, completion: OperationCompletionBlock?) {
			self.objects = objects
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completion)
		}
		
		override func main() {
			let context = persistentContainer.newBackgroundContext()
			result = Save.execute(objects: objects, context: context)
		}
		
		class func execute(objects: [[String : Any]], context: NSManagedObjectContext) -> ResultType {
			let request = NSBatchInsertRequest(entityName: String(describing: UserListItem.self), objects: objects)
			var result: ResultType!
			context.performAndWait {
				do {
					try context.execute(request)
					result = .success(nil)
				} catch {
					result = .failure(error)
				}
			}
			return result
		}
		
	}
}
