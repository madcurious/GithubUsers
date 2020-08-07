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
		let context: NSManagedObjectContext
		
		init(urlString: String, imageData: Data, context: NSManagedObjectContext, completion: OperationCompletionBlock?) {
			self.urlString = urlString
			self.imageData = imageData
			self.context = context
			super.init(completionBlock: completion)
		}
		
		override func main() {
			result = Save.execute(urlString: urlString, imageData: imageData, context: context)
		}
		
		class func execute(urlString: String, imageData: Data, context: NSManagedObjectContext) -> Save.ResultType {
			guard let image = NSEntityDescription.insertNewObject(forEntityName: String(describing: Image.self), into: context) as? Image
				else {
					return .failure(CoreDataServiceError.failedCast(NSManagedObject.self, Image.self))
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
