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
		let context: NSManagedObjectContext
		let coreDataQueue: OperationQueue
		
		var fetchOperation: HTTPService.Image.Fetch?
		var saveOperation: CoreDataService.Image.Save?
		
		init(urlString: String, urlSession: URLSession, httpServiceQueue: OperationQueue, context: NSManagedObjectContext, coreDataQueue: OperationQueue, completion: OperationCompletionBlock?) {
			self.urlString = urlString
			self.urlSession = urlSession
			self.httpServiceQueue = httpServiceQueue
			self.context = context
			self.coreDataQueue = coreDataQueue
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
				let saveOperation = CoreDataService.Image.Save(urlString: urlString, imageData: imageData, context: context, completion: nil)
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
