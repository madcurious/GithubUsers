//
//  HTTPServiceError.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

/// Common HTTP service errors.
enum HTTPServiceError: LocalizedError {
	
	/// The request URL is invalid.
	case invalidUrl(_ urlString: String)
	
	/// The request did not succeed.
	case requestFailed(_ error: Swift.Error)
	
	/// The request succeeded but the server returned no data.
	case serverReturnedNoData
	
	var errorDescription: String? {
		switch self {
		case .invalidUrl(let string):
			return "Invalid URL: \(string)"
		case .requestFailed(let error):
			return "Request failed: \(error.localizedDescription)"
		case .serverReturnedNoData:
			return "The request succeeded but the server returned no data."
		}
	}
	
}
