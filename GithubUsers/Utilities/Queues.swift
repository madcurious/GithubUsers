//
//  Queues.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/7/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

/// Contains shared operation queues.
final class Queues {
	
	/// The shared operation queue for HTTP services.
	static let http: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
	
	/// The shared operation queue for Core Data services.
	static let coreData: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
	
	/// The shared operation queue for the combined fetch-and-save service for images.
	static let images = OperationQueue()
	
}
