//
//  CoreDataService_UserProfile_Fetch.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.UserProfile {
	
	/// Queries a user profile by username on a given context. If successful, the result holds a `UserProfile` if a profile is found or `nil` if none.
	/// If failed, the result holds an error.
	class Fetch {
		
		/// Executes a profile fetch on a given context.
		/// - Parameters:
		///		- username: The username to be queried.
		///		- context: The context from which to fetch the object.
		class func execute(username: String, context: NSManagedObjectContext) -> Result<UserProfile?, Error> {
			let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(UserProfile.username), username)
			do {
				let result = try context.fetch(fetchRequest)
				return .success(result.first)
			} catch {
				return .failure(error)
			}
		}
		
	}
	
}
