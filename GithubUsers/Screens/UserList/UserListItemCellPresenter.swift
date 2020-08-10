//
//  UserListItemCellPresenter.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

class UserListItemCellPresenter: ModelPresenter {
	
	typealias ModelType = UserListItem
	typealias ViewType = UserListItemCell
	
	var currentImageURLString: String?
	
	let invertsImageColors: Bool
	
	init(invertsImageColors: Bool) {
		self.invertsImageColors = invertsImageColors
	}
	
	func present(_ model: UserListItem?, in view: UserListItemCell) {
		guard let model = model
			else {
				view.avatarImageView.image = nil
				view.headerLabel.text = nil
				view.detailLabel.text = nil
				currentImageURLString = nil
				return
		}
		view.headerLabel.text = model.username
		view.detailLabel.text = "Github user ID: \(model.id)"

		guard let urlString = model.avatarURLString
			else {
				return
		}
		currentImageURLString = urlString
		if let image = UserListItemCellPresenter.fetchImageFromCache(urlString: urlString, context: CoreDataStack.shared.viewContext) {
			view.avatarImageView.image = image
		} else {
			fetchImageFromRemoteSource(urlString: urlString, view: view)
		}
	}
	
	class func fetchImageFromCache(urlString: String, context: NSManagedObjectContext) -> UIImage? {
		let fetchResult = CoreDataService.Image.Fetch.execute(urlString: urlString, context: context)
		if case .success(let someData) = fetchResult,
			let data = someData {
			return UIImage(data: data)
		}
		return nil
	}
	
	func fetchImageFromRemoteSource(urlString: String, view: UserListItemCell) {
		// If a combined operation for urlString already exists, do not continue.
		if Queues.images.operations.contains(where: { ($0 as? CombinedService.Image.FetchAndSave)?.urlString == urlString }) {
			return
		}
		
		let retryID = "\(CombinedService.self).\(CombinedService.Image.self).\(CombinedService.Image.FetchAndSave.self).\(urlString)"
		let operation = CombinedService.Image.FetchAndSave(urlString: urlString) { (operation) in
				guard let operation = operation as? CombinedService.Image.FetchAndSave,
					operation.urlString == self.currentImageURLString,
					operation.isCancelled == false,
					let result = operation.result,
					case .success(let imageData) = result
					else {
						RetryController.shared.mark(identifier: retryID) {
							self.fetchImageFromRemoteSource(urlString: urlString, view: view)
						}
						return
				}
				DispatchQueue.main.async {
					view.avatarImageView.image = UIImage(data: imageData)
				}
		}
		Queues.images.addOperation(operation)
	}
	
}
