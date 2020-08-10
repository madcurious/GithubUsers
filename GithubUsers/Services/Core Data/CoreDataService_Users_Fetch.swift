//
//  CoreDataService_Users_Fetch.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/11/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.Users {
	
	class Fetch {
		
		class func execute(username: String, context: NSManagedObjectContext) -> Result<UserListItem?, Error> {
			var result: Result<UserListItem?, Error>!
			context.performAndWait {
				let fetchRequest: NSFetchRequest<UserListItem> = UserListItem.fetchRequest()
				fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(UserListItem.username), username)
				do {
					let fetchResult = try context.fetch(fetchRequest)
					result = .success(fetchResult.first)
				} catch {
					result = .failure(error)
				}
			}
			return result
		}
		
	}
	
}
