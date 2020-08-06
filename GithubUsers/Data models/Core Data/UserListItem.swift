//
//  UserListItem.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

extension UserListItem {
	
	class func makeObjectDictionary(from model: RawUserListItem) -> [String : Any] {
		var dictionary = [String : Any]()
		if let avatarURLString = model.avatar_url {
			dictionary[#keyPath(UserListItem.avatarURLString)] = avatarURLString
		}
		if let id = model.id {
			dictionary[#keyPath(UserListItem.id)] = id
		}
		if let username = model.login {
			dictionary[#keyPath(UserListItem.username)] = username
		}
		return dictionary
	}
	
	class RawModelValidator: ModelValidator {
		typealias ModelType = RawUserListItem
		typealias ErrorType = ValidationError
		
		enum ValidationError: LocalizedError {
			case missingKey(_ name: String)
		}
		
		static func validate(_ model: RawUserListItem) -> Result<RawUserListItem, ValidationError> {
			if model.id == nil {
				return .failure(.missingKey("id"))
			}
			if model.login == nil {
				return .failure(.missingKey("login"))
			}
			return .success(model)
		}
	}
	
}
