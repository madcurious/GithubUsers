//
//  CoreDataService+Image.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService {
	class Image {
		
		class func fetch(urlString: String, context: NSManagedObjectContext) -> Result<GithubUsers.Image?, Error> {
			let fetchRequest: NSFetchRequest<GithubUsers.Image> = GithubUsers.Image.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(GithubUsers.Image.urlString), urlString)
			do {
				let matches = try context.fetch(fetchRequest)
				switch matches.count {
				case let count where count > 1:
					throw CoreDataServiceError.duplicatesFound(GithubUsers.Image.self, urlString)
				default:
					return .success(matches.first)
				}
			} catch {
				return .failure(error)
			}
		}
		
		class func insert(urlString: String, imageData: Data, context: NSManagedObjectContext) -> Result<NSManagedObjectID, Swift.Error> {
			guard let image = NSEntityDescription.insertNewObject(forEntityName: String(describing: GithubUsers.Image.self), into: context) as? GithubUsers.Image
				else {
					return .failure(CoreDataServiceError.failedCast(NSManagedObject.self, GithubUsers.Image.self))
			}
			image.urlString = urlString
			image.data = imageData
			do {
				try context.save()
				return .success(image.objectID)
			} catch {
				return .failure(error)
			}
		}
		
	}
}
