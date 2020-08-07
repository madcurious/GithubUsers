//
//  CoreDataService_Image_Fetch.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/7/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.Image {
	
	class Fetch: Operation<Data?, Error> {
		
		let urlString: String
		let context: NSManagedObjectContext
		
		init(urlString: String, context: NSManagedObjectContext, completion: OperationCompletionBlock?) {
			self.urlString = urlString
			self.context = context
			super.init(completionBlock: completion)
		}
		
		override func main() {
			result = Fetch.execute(urlString: urlString, context: context)
		}
		
		class func execute(urlString: String, context: NSManagedObjectContext) -> Fetch.ResultType {
			let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Image.urlString), urlString)
			do {
				let matches = try context.fetch(fetchRequest)
				switch matches.count {
				case let count where count > 1:
					throw CoreDataServiceError.duplicatesFound(GithubUsers.Image.self, urlString)
				default:
					return .success(matches.first?.data)
				}
			} catch {
				return .failure(error)
			}
		}
		
	}
	
}
