//
//  HTTPService.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

/// Container class for HTTP services.
class HTTPService {
	
	static let urlSessionConfiguration = URLSessionConfiguration.default
	
	/// The shared `URLSession` for all HTTP services.
	static let urlSession = URLSession(configuration: urlSessionConfiguration)
	
	/// The shared operation queue for all HTTP services.
	static let queue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
	
	class Users { }
	
}
