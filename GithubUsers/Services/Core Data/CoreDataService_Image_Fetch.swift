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
		
		class func execute(urlString: String, context: NSManagedObjectContext) -> Result<Data?, Error> {
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
