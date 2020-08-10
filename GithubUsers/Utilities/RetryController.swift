//
//  RetryController.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/8/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

class RetryController: NSObject {
	
	static let shared = RetryController()
	
	/// The blocks waiting to be retried.
	fileprivate var pending: [String : () -> Void]
	
	/// The parallel queue that runs all pending blocks once invoked.
	fileprivate let runQueue: OperationQueue
	
	override init() {
		pending = [:]
		runQueue = OperationQueue()
		super.init()
		NotificationCenter.default.addObserver(self, selector: #selector(handleReachabilityChangedNotification(_:)), name: NSNotification.Name.reachabilityChanged, object: Reachability.shared)
	}
	
	/// Sets a block as pending retrial.
	func mark(identifier: String, block: @escaping () -> Void) {
		pending[identifier] = block
	}
	
	/// Resets the retry queue (e.g. when the user pulls to refresh) and cancels all ongoing operations.
	func reset() {
		runQueue.cancelAllOperations()
		pending = [:]
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	/// Invoked when reachability changes.
	@objc func handleReachabilityChangedNotification(_ notification: NSNotification) {
		guard let sender = notification.object as? Reachability,
			sender == Reachability.shared
			else {
				return
		}
		let (networkStatus, requiresConnection) = (sender.currentReachabilityStatus(), sender.connectionRequired())
		switch (networkStatus, requiresConnection) {
		case (.ReachableViaWiFi, false), (.ReachableViaWWAN, false):
			let operations = pending.map({ BlockOperation(block: $0.value) })
			runQueue.addOperations(operations, waitUntilFinished: false)
			pending = [:]
		default:
			break
		}
	}
	
}
