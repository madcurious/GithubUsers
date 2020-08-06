//
//  ModelValidator.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

/// Validates a data model. Uses include determining whether a raw data model is valid as a Core Data managed object.
protocol ModelValidator {
	
	associatedtype ModelType
	associatedtype ErrorType: Error
	
	/// Returns the model if the model is valid, or an error if invalid.
	static func validate(_ model: ModelType) -> Result<ModelType, ErrorType>
	
	/// Returns `true` if a model is valid or `false` if invalid. To get more specific validation errors, use `validate(_:)` instead.
	static func isValid(_ model: ModelType) -> Bool
	
}

extension ModelValidator {
	
	static func isValid(_ model: ModelType) -> Bool {
		if case .success(_) = validate(model) {
			return true
		}
		return false
	}
	
}
