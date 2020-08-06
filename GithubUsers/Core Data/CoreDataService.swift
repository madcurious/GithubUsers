//
//  CoreDataService.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

class CoreDataService {
	
	class func deleteAllRecords(context: NSManagedObjectContext) -> Result<Int, Error> {
		let requests = [
			GithubUsers.UserListItem.fetchRequest(),
			GithubUsers.UserProfile.fetchRequest(),
			GithubUsers.Image.fetchRequest()
		]
		do {
			var deletedObjectsCount = 0
			for request in requests {
				let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
				deleteRequest.resultType = .resultTypeCount
				let deleteResult = try context.execute(deleteRequest) as? NSBatchDeleteResult
				if let count = deleteResult?.result as? Int {
					deletedObjectsCount += count
				}
			}
			return .success(deletedObjectsCount)
		} catch {
			return .failure(error)
		}
	}
	
	/// Services with relation to lists of users.
	class Users { }
	
	/// Services with relation to all records in the Core Data cache.
	class AllRecords { }
	
}

