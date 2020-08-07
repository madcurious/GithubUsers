//
//  UserListItemCellDefault+DefaultPresenter.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

extension UserListItemCellDefault {
	
	class DefaultPresenter: ModelPresenter {
		
		typealias ModelType = UserListItem
		typealias ViewType = UserListItemCellDefault
		
		var currentImageUrlString: String?
		
		func present(_ model: UserListItem?, in view: UserListItemCellDefault) {
			guard let model = model
				else {
					view.avatarImageView.image = nil
					view.headerLabel.text = nil
					view.detailLabel.text = nil
					currentImageUrlString = nil
					return
			}
			view.headerLabel.text = model.username
			view.detailLabel.text = "Github user ID: \(model.id)"
			
			if let urlString = model.avatarURLString {
				currentImageUrlString = urlString
				loadImage(urlString: urlString, view: view)
			}
		}
		
		func loadImage(urlString: String, view: UserListItemCellDefault) {
			if let image = DefaultPresenter.fetchImageFromCache(urlString: urlString, context: CoreDataStack.shared.viewContext) {
				view.avatarImageView.image = image
				return
			}
			
			// If a combined operation for urlString already exists, do not continue.
			if Queues.images.operations.contains(where: { ($0 as? CombinedService.Image.FetchAndSave)?.urlString == urlString }) {
				return
			}
			
			let operation = CombinedService.Image.FetchAndSave(
				urlString: urlString,
				urlSession: HTTPService.urlSession,
				httpServiceQueue: Queues.http,
				context: CoreDataStack.shared.newBackgroundContext(),
				coreDataQueue: Queues.coreData) { (operation) in
					guard let operation = operation as? CombinedService.Image.FetchAndSave,
						operation.urlString == self.currentImageUrlString,
						operation.isCancelled == false,
						let result = operation.result,
						case .success(let imageData) = result
						else {
							return
					}
					DispatchQueue.main.async {
						view.avatarImageView.image = UIImage(data: imageData)
					}
			}
			Queues.images.addOperation(operation)
		}
		
		class func fetchImageFromCache(urlString: String, context: NSManagedObjectContext) -> UIImage? {
			let fetchResult = CoreDataService.Image.Fetch.execute(urlString: urlString, context: context)
			if case .success(let someData) = fetchResult,
				let data = someData {
				return UIImage(data: data)
			}
			return nil
		}
		
	}
	
}
