//
//  CoreDataService_Image_Save.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/7/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

extension CoreDataService.Image {
	
	class Save: Operation<NSManagedObjectID, Error> {
		
		let urlString: String
		let imageData: Data
		let persistentContainer: NSPersistentContainer
		
		init(urlString: String, imageData: Data, persistentContainer: NSPersistentContainer, completion: OperationCompletionBlock?) {
			self.urlString = urlString
			self.imageData = imageData
			self.persistentContainer = persistentContainer
			super.init(completionBlock: completion)
		}
		
		override func main() {
			result = Save.execute(urlString: urlString, imageData: imageData, context: persistentContainer.newBackgroundContext())
		}
		
		class func execute(urlString: String, imageData: Data, context: NSManagedObjectContext) -> Save.ResultType {
			var result: Save.ResultType!
			context.performAndWait {
				guard let image = NSEntityDescription.insertNewObject(forEntityName: String(describing: Image.self), into: context) as? Image
					else {
						result = .failure(CoreDataServiceError.failedCast(NSManagedObject.self, Image.self))
						return
				}
				image.urlString = urlString
				image.data = imageData
				do {
					try context.save()
					result = .success(image.objectID)
				} catch {
					result = .failure(error)
				}
			}
			return result
		}
		
	}
	
}
