//
//  UserProfileView_DefaultPresenter.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

extension UserProfileView {
	
	class DefaultPresenter: ModelPresenter {
		
		typealias ModelType = UserProfile
		typealias ViewType = UserProfileView
		
		var currentImageURLString: String?
		
		func present(_ model: UserProfile?, in view: UserProfileView) {
			guard let model = model
				else {
					view.avatarImageView = nil
					view.idLabel.text = nil
					view.usernameLabel.text = nil
					view.nameLabel.text = nil
					view.followersLabel.text = nil
					view.followingLabel.text = nil
					view.descriptionLabel.text = nil
					view.noteTextField.text = nil
					currentImageURLString = nil
					return
			}
			
			view.idLabel.text = String(format: "%d", model.id)
			view.usernameLabel.text = model.username
			view.nameLabel.text = model.fullName
			view.followersLabel.text = String(format: "%d", model.followers)
			view.followingLabel.text = String(format: "%d", model.following)
			view.descriptionLabel.text = makeDescriptionText(for: model)
			view.noteTextField.text = model.note
			
			guard let urlString = model.avatarURLString
				else {
					return
			}
			currentImageURLString = urlString
			if let image = DefaultPresenter.fetchImageFromCache(urlString: urlString, context: CoreDataStack.shared.viewContext) {
				view.avatarImageView.image = image
			} else {
				fetchImageFromRemoteSource(urlString: urlString, view: view)
			}
		}
		
		func makeDescriptionText(for model: UserProfile) -> String {
			switch (model.bio, model.company, model.location, model.joinDate) {
			case (.some(let bio), _, _, _):
				return bio
			case (nil, .some(let company), _, _):
				return "Works at \(company)"
			case (nil, nil, .some(let location), _):
				return "In \(location)"
			case (nil, nil, nil, .some(let joinDate)):
				return "Joined \(DateFormatter.shared.string(from: joinDate)))"
			default:
				return "Just another Github user"
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
		
		func fetchImageFromRemoteSource(urlString: String, view: UserProfileView) {
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
	
}
