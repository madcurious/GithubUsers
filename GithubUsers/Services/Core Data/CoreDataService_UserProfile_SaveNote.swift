//
//  CoreDataService_UserProfile_SaveNote.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.UserProfile {
	
	class SaveNote: Operation<Any?, Error> {
		
		let username: String
		let note: String?
		let persistentContainer: NSPersistentContainer
		
		init(username: String, note: String?, persistentContainer: NSPersistentContainer, completionBlock: OperationCompletionBlock?) {
			self.username = username
			self.note = note
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completionBlock)
		}
		
		override func main() {
			result = SaveNote.execute(username: username, note: note, context: persistentContainer.newBackgroundContext())
		}
		
		/// Saves a note for the user with the given username. This function updates the managed objects for the user profile and the user list item.
		///	- Parameters:
		///		- username: The username of the user to be modified.
		///		- note: The note to be added. A `nil` note deletes a note.
		///		- context: The `NSManagedObjectContext` from and in which to fetch, modify, and save the relevant entities.
		class func execute(username: String, note: String?, context: NSManagedObjectContext) -> Result<Any?, Error> {
			var result: Result<Any?, Error>!
			context.performAndWait {
				// First, update the profile object.
				let fetchResult = CoreDataService.UserProfile.Fetch.execute(username: username, context: context)
				switch fetchResult {
				case .failure(let error):
					result = .failure(error)
					return
				case .success(let userProfile):
					guard let userProfile = userProfile
						else {
							result = .failure(CoreDataServiceError.notFound(UserProfile.self, "username", username))
							return
					}
					userProfile.note = note
					
					// Next, update the user list item object.
					let fetchResult = CoreDataService.Users.Fetch.execute(username: username, context: context)
					switch fetchResult {
					case .failure(let error):
						result = .failure(error)
					case .success(let userListItem):
						userListItem?.hasNote = note != nil
					}
					
					// Save the changes.
					do {
						try context.save()
						result = .success(nil)
					} catch {
						result = .failure(error)
					}
				}
			}
			
			return result
		}
		
	}
	
}
