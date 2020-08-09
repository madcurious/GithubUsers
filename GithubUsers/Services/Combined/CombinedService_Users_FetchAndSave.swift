//
//  CombinedService_Users_FetchAndSave.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CombinedService.Users {
	
	/// Fetches a list of users over the network, optionally purges all records in Core Data, then saves the results to Core Data.
	/// If successful, the result holds either the last user ID in the list or `nil` if no users were returned, suggesting that the last page
	/// has been reached; otherwise, the result holds an `Error`.
	class FetchAndSave: Operation<Int?, Error> {
		
		let userID: Int
		let shouldPurgeCache: Bool
		let urlSession: URLSession
		let httpServiceQueue: OperationQueue
		let coreDataQueue: OperationQueue
		let persistentContainer: NSPersistentContainer
		
		weak var purgeService: CoreDataService.AllRecords.Purge?
		weak var fetchService: HTTPService.Users.Fetch?
		weak var saveService: CoreDataService.Users.Save?
		
		/// Creates a new instance.
		/// - Parameters:
		///		- userID: The user ID passed in Github Users API's `since` parameter.
		///		- shouldPurgeCache: If true, all records in the persistent store are deleted before saving.
		///		- urlSession: The `URLSession` to be used for the network request.
		/// 	- httpServiceQueue: The queue to which the HTTP service will be dispatched.
		/// 	- coreDataQueue: The queue to which the Core Data save operation will be dispatched.
		/// 	- persistentContainer: The `NSPersistentContainer` to create all `NSManagedObjectContext`s necessary for the underlying Core Data services.
		///		- completion: Executed when the operation finishes.
		init(since userID: Int,
				 shouldPurgeCache: Bool,
				 urlSession: URLSession = HTTPService.urlSession,
				 httpServiceQueue: OperationQueue = Queues.http,
				 coreDataQueue: OperationQueue = Queues.coreData,
				 persistentContainer: NSPersistentContainer = CoreDataStack.shared,
				 completion: OperationCompletionBlock?) {
			self.userID = userID
			self.shouldPurgeCache = shouldPurgeCache
			self.urlSession = urlSession
			self.httpServiceQueue = httpServiceQueue
			self.coreDataQueue = coreDataQueue
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completion)
		}
		
		override func cancel() {
			super.cancel()
			fetchService?.cancel()
			purgeService?.cancel()
			saveService?.cancel()
		}
		
		override func main() {
			let fetchService = HTTPService.Users.Fetch(since: userID, urlSession: urlSession, completion: nil)
			self.fetchService = fetchService
			httpServiceQueue.addOperations([fetchService], waitUntilFinished: true)
			
			guard isCancelled == false && fetchService.isCancelled == false,
				let fetchResult = fetchService.result
				else {
					return
			}
			
			switch fetchResult {
			case .failure(let error):
				result = .failure(error)
				
			case .success(let rawItems):
				if shouldPurgeCache {
					do {
						try purge()
					} catch {
						result = .failure(error)
						return
					}
				}
				
				guard rawItems.isEmpty == false
					else {
						result = .success(nil)
						return
				}
				
				let objects = rawItems.map({ UserListItem.makeObjectDictionary(from: $0) })
				let saveService = CoreDataService.Users.Save(objects: objects, persistentContainer: persistentContainer, completion: nil)
				self.saveService = saveService
				coreDataQueue.addOperations([saveService], waitUntilFinished: true)
				
				guard isCancelled == false && saveService.isCancelled == false,
					let saveResult = saveService.result
					else {
						return
				}
				
				switch saveResult {
				case .failure(let error):
					result = .failure(error)
				case .success(_):
					result = .success(rawItems.last?.id)
				}
				
			}
		}
		
		func purge() throws {
			let purgeService = CoreDataService.AllRecords.Purge(persistentContainer: persistentContainer, completion: nil)
			self.purgeService = purgeService
			coreDataQueue.addOperations([purgeService], waitUntilFinished: true)
			guard let result = purgeService.result
				else {
					throw CoreDataServiceError.unexpectedNil(type(of: purgeService), "result")
			}
			if case .failure(let error) = result {
				throw error
			}
		}
		
	}
}
