//
//  CombinedService_UserProfile_FetchAndSave.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CombinedService.UserProfile {
	
	/// Fetches a user by username over the network, then caches the result in Core Data. If successful, the result holds the object ID
	/// of the cached object; otherwise the result holds an error.
	class FetchAndSave: Operation<NSManagedObjectID, Error> {
		
		let username: String
		let urlSession: URLSession
		let httpServiceQueue: OperationQueue
		let coreDataQueue: OperationQueue
		let persistentContainer: NSPersistentContainer
		
		fileprivate var fetchOperation: Foundation.Operation?
		fileprivate var saveOperation: Foundation.Operation?
		
		init(username: String,
				 urlSession: URLSession = HTTPService.urlSession,
				 httpServiceQueue: OperationQueue = Queues.http,
				 coreDataQueue: OperationQueue = Queues.coreData,
				 persistentContainer: NSPersistentContainer = CoreDataStack.shared,
				 completionBlock: OperationCompletionBlock?) {
			self.username = username
			self.urlSession = urlSession
			self.httpServiceQueue = httpServiceQueue
			self.coreDataQueue = coreDataQueue
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completionBlock)
		}
		
		override func cancel() {
			super.cancel()
			fetchOperation?.cancel()
			saveOperation?.cancel()
		}
		
		override func main() {
			let fetchOperation = HTTPService.UserProfile.Fetch(username: username, urlSession: urlSession, completionBlock: nil)
			self.fetchOperation = fetchOperation
			httpServiceQueue.addOperations([fetchOperation], waitUntilFinished: true)
			
			guard isCancelled == false && fetchOperation.isCancelled == false,
				let fetchResult = fetchOperation.result
				else {
					return
			}
			switch fetchResult {
			case .failure(let error):
				result = .failure(error)
				
			case .success(let rawUserProfile):
				let saveOperation = CoreDataService.UserProfile.Save(source: rawUserProfile, persistentContainer: persistentContainer, completionBlock: nil)
				self.saveOperation = saveOperation
				coreDataQueue.addOperations([saveOperation], waitUntilFinished: true)
				guard isCancelled == false && saveOperation.isCancelled == false,
					let saveResult = saveOperation.result
					else {
						return
				}
				switch saveResult {
				case .failure(let error):
					result = .failure(error)
				case .success(let objectID):
					result = .success(objectID)
				}
			}
		}
		
	}
	
}
