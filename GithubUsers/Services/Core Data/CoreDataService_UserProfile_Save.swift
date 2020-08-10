//
//  CoreDataService_UserProfile_Save.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.UserProfile {
	
	/// Saves a `UserProfile` object in Core Data based on a raw data model fetched over the network. If successful, the result holds \
	/// the object ID of the saved profile; otherwise the result holds an error.
	class Save: Operation<NSManagedObjectID, Error> {
		
		let source: RawUserProfile
		let persistentContainer: NSPersistentContainer
		
		init(source: RawUserProfile, persistentContainer: NSPersistentContainer, completionBlock: OperationCompletionBlock?) {
			self.source = source
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completionBlock)
		}
		
		override func main() {
			result = Save.execute(source: source, context: persistentContainer.newBackgroundContext())
		}
		
		class func execute(source: RawUserProfile, context: NSManagedObjectContext) -> ResultType {
			var result: ResultType!
			context.performAndWait {
				guard let profile = NSEntityDescription.insertNewObject(forEntityName: String(describing: UserProfile.self), into: context) as? UserProfile
					else {
						result = .failure(CoreDataServiceError.failedCast(NSManagedObjectContext.self, UserProfile.self))
						return
				}
				
				profile.avatarURLString = source.avatar_url
				profile.bio = source.bio
				profile.company = source.company
				profile.email = source.email
				if let followers = source.followers {
					profile.followers = Int64(followers)
				}
				if let following = source.following {
					profile.following = Int64(following)
				}
				profile.fullName = source.name
				if let userID = source.id {
					profile.id = Int64(userID)
				}
				if let joinDateString = source.created_at {
					profile.joinDate = DateFormatter.shared.date(from: joinDateString)
				}
				profile.location = source.location
				profile.username = source.login
				
				do {
					try context.save()
					result = .success(profile.objectID)
				} catch {
					result = .failure(error)
				}
			}
			return result
		}
		
	}
	
}
