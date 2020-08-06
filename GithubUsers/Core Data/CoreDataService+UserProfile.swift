//
//  CoreDataService+UserProfile.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService {
	class UserProfile {
		
		fileprivate static let dateFormatter = ISO8601DateFormatter()
		
		/// Fetches a `UserProfile` with a given `username`.
		/// - Parameters:
		///		- username: The username to be queried.
		///		- context: The context from which to fetch the object.
		class func fetch(username: String, context: NSManagedObjectContext) -> Result<GithubUsers.UserProfile?, Error> {
			let fetchRequest: NSFetchRequest<GithubUsers.UserProfile> = GithubUsers.UserProfile.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(GithubUsers.UserProfile.username), username)
			do {
				let result = try context.fetch(fetchRequest)
				if result.count > 1 {
					throw CoreDataServiceError.duplicatesFound(UserProfile.self, username)
				}
				return .success(result.first)
			} catch {
				return .failure(error)
			}
		}
		
		/// Inserts a new `UserProfile` from a raw model.
		/// - Parameters:
		///		- rawUserProfile: The source raw data model.
		///		- context: The context into which the entity will be inserted and saved.
		class func insert(rawUserProfile: RawUserProfile, context: NSManagedObjectContext) -> Result<NSManagedObjectID, Swift.Error> {
			guard let profile = NSEntityDescription.insertNewObject(forEntityName: String(describing: GithubUsers.UserProfile.self), into: context) as? GithubUsers.UserProfile
				else {
					return .failure(CoreDataServiceError.failedCast(NSManagedObjectContext.self, GithubUsers.UserProfile.self))
			}
			profile.avatarURLString = rawUserProfile.avatar_url
			profile.bio = rawUserProfile.bio
			profile.company = rawUserProfile.company
			profile.email = rawUserProfile.email
			profile.fullName = rawUserProfile.name
			if let userID = rawUserProfile.id {
				profile.id = Int64(userID)
			}
			if let createdAtString = rawUserProfile.created_at {
				profile.joinDate = dateFormatter.date(from: createdAtString)
			}
			profile.location = rawUserProfile.location
			profile.username = rawUserProfile.login
			do {
				try context.save()
				return .success(profile.objectID)
			} catch {
				return .failure(error)
			}
		}
		
		/// Updates `UserProfile.note` and `UserListItem.hasNote` for the user with the provided `username`.
		/// If successful, returns the `UserProfile`'s managed object ID.
		/// - Parameters:
		///		- note: The note to be saved. A `nil` note deletes the current note.
		///		- username: The username of the profile to be updated.
		///		- context: The context from which to fetch and save the associated managed objects with the username.
		class func saveNote(_ note: String?, username: String, context: NSManagedObjectContext) -> Result<NSManagedObjectID, Swift.Error> {
			do {
				let profileFetch: NSFetchRequest<GithubUsers.UserProfile> = GithubUsers.UserProfile.fetchRequest()
				profileFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(GithubUsers.UserProfile.username), username)
				guard let userProfile = try context.fetch(profileFetch).first
					else {
						throw CoreDataServiceError.notFound(GithubUsers.UserProfile.self, #keyPath(GithubUsers.UserProfile.username), username)
				}
				userProfile.note = note
				
				let previewFetch: NSFetchRequest<GithubUsers.UserListItem> = GithubUsers.UserListItem.fetchRequest()
				previewFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(GithubUsers.UserListItem.username), username)
				guard let userPreview = try context.fetch(previewFetch).first
					else {
						throw CoreDataServiceError.notFound(GithubUsers.UserListItem.self, #keyPath(GithubUsers.UserListItem.username), username)
				}
				userPreview.hasNote = note != nil
				
				try context.save()
				return .success(userProfile.objectID)
			} catch {
				return .failure(error)
			}
		}
		
	}
}
