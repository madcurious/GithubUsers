//
//  CoreDataService+UserListItem.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import CoreData

class CoreDataService+UserListItem {
	
	class func insertBatch(rawPreviews: [RawUserListItem], context: NSManagedObjectContext) -> Result<Int, Error> {
		let dictionaries = rawPreviews.map({ UserListItem.makeObjectDictionary(from: $0) })
		let request = NSBatchInsertRequest(entityName: String(describing: UserListItem.self), objects: dictionaries)
		request.resultType = .count
		do {
			let batchInsertResult = try context.execute(request) as? NSBatchInsertResult
			return .success(batchInsertResult?.result as? Int ?? 0)
		} catch {
			return .failure(error)
		}
	}
	
}
