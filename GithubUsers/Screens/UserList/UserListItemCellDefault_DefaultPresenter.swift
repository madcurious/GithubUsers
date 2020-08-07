//
//  UserListItemCellDefault+DefaultPresenter.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

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
			currentImageUrlString = model.avatarURLString
		}
		
	}
	
}
