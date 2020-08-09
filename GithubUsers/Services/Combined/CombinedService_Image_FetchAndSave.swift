//
//  CombinedService_Image_FetchAndSave.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/7/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CombinedService.Image {
	
	class FetchAndSave: Operation<Data, Error> {
		
		let urlString: String
		let urlSession: URLSession
		let httpServiceQueue: OperationQueue
		let coreDataQueue: OperationQueue
		let persistentContainer: NSPersistentContainer
		
		fileprivate(set) var fetchOperation: HTTPService.Image.Fetch?
		fileprivate(set) var saveOperation: CoreDataService.Image.Save?
		
		/// Creates an instance of the operation.
		/// - Parameters:
		///		- urlString: The remote location from which to fetch the image.
		///		- urlSession: The `URLSession` object to create the data task.
		///		- httpServiceQueue: The `OperationQueue` to which the underlying HTTP service is dispatched.
		///		- coreDataQueue: The `OperationQueue` to which the underlying Core Data service is dispatched.
		///		- persistentContainer: The `NSPersistentContainer` which will create the background `NSManageObjectContext`.
		///		- completion: The completion block.
		init(urlString: String,
				 urlSession: URLSession = HTTPService.urlSession,
				 httpServiceQueue: OperationQueue = Queues.http,
				 coreDataQueue: OperationQueue = Queues.coreData,
				 persistentContainer: NSPersistentContainer = CoreDataStack.shared,
				 completion: OperationCompletionBlock?) {
			self.urlString = urlString
			self.urlSession = urlSession
			self.httpServiceQueue = httpServiceQueue
			self.coreDataQueue = coreDataQueue
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completion)
		}
		
		override func cancel() {
			super.cancel()
			fetchOperation?.cancel()
			saveOperation?.cancel()
		}
		
		override func main() {
			let fetchOperation = HTTPService.Image.Fetch(urlString: urlString, urlSession: urlSession, completion: nil)
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
				
			case .success(let imageData):
				let saveOperation = CoreDataService.Image.Save(urlString: urlString, imageData: imageData, persistentContainer: persistentContainer, completion: nil)
				self.saveOperation = saveOperation
				coreDataQueue.addOperations([saveOperation], waitUntilFinished: true)
				
				guard isCancelled == false && saveOperation.isCancelled == false,
					let saveResult = saveOperation.result
					else {
						return
				}
				switch saveResult {
				case .failure(let error):
					self.result = .failure(error)
				case .success(_):
					self.result = .success(imageData)
				}
			}
		}
		
	}
	
}
