//
//  CoreDataServiceError.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

/// An error for any of the service operations.
enum CoreDataServiceError: LocalizedError {
	
	case duplicatesFound(_ type: AnyClass, _ identifier: String)
	case failedCast(_ originalType: AnyClass, _ targetType: AnyClass)
	case notFound(_ entityType: AnyClass, _ key: String, _ value: String)
	case unexpectedNil(_ type: AnyClass, _ key: String)
	
	var errorDescription: String? {
		switch self {
		case .duplicatesFound(let type, let identifier):
			return "Duplicates of type \(String(describing: type)) found for identifier \(identifier)"
		case .failedCast(let originalType, let targetType):
			return "Failed to cast \(String(describing: originalType)) to \(String(describing: targetType))"
		case .notFound(let entityType, let key, let value):
			return "Did not find \(String(describing: entityType)) with '\(key)' of value '\(value)'"
		case .unexpectedNil(let type, let key):
			return "Unexpected nil in \(String(describing: type)).\(key)"
		}
	}
	
}
