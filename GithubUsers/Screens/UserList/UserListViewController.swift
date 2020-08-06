//
//  UserListViewController.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 7/21/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Main class
class UserListViewController: UIViewController {
	
	enum RetryActionName: String {
		case remoteFetchAndLocalSaveFromZero
		case remoteFetchAndLocalSaveNextPage
	}
	
	/// The main view, set in Main.storyboard.
	@IBOutlet var customView: UserListView!
	
	/// The `NSFetchedResultsController` that provides the list data.
	var fetchController: NSFetchedResultsController<UserListItem>!
	
//	/// The action invoked by the retry button.
//	var currentRetriableAction: (() -> Void)?
	let retryController = RetryController()
	
	/// Indicates when to fetch the next batch of results over the network. If there are *n* currently loaded results,
	/// the next batch is loaded when the cell at *n* minus the threshold is displayed.
	let fetchThreshold = 5
	
	/// Derives whether there are more results to fetch, as indicated by whether the table view footer is shown or hidden.
	var hasMoreResults: Bool {
		return customView.tableView.tableFooterView != nil
	}
	
	fileprivate var hasAppearedBefore = false
	
	var selectedIndexPath: IndexPath?
	
	let queue = OperationQueue()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTableView()
		
		// Set up target-action mechanisms.
		customView.refreshControl.addTarget(self, action: #selector(handlePullOnRefreshControl), for: .valueChanged)
		customView.actionButton.addTarget(self, action: #selector(handleTapOnActionButton), for: .touchUpInside)
		
		// Observe reachability changes.
		NotificationCenter.default.addObserver(self, selector: #selector(handleReachabilityChangedNotification(notification:)), name: NSNotification.Name.reachabilityChanged, object: Reachability.shared)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Open the gates of hell.
		if hasAppearedBefore == false {
			begin()
			hasAppearedBefore = true
		}
	}
	
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		guard segue.identifier == Segues.toUserProfile,
//			let userProfileVC = segue.destination as? UserProfileViewController,
//			let indexPath = selectedIndexPath
//			else {
//				return
//		}
//		userProfileVC.username = fetchedResultsController.object(at: indexPath).username
//	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
	}
	
}

// MARK: - View State
fileprivate extension UserListViewController {
	
	/// Shows the view for displaying errors.
	func showFailureView(forError error: Error) {
		customView.informationLabel.text = error.localizedDescription
		customView.actionButton.isHidden = retryController.hasMarkedAction == false
		customView.showMoreIndicator(false)
		customView.state = .failure
	}
	
	/// Shows the view for when there are no Github users.
	func showNoUsersView() {
		customView.informationLabel.text = "There are no Github users."
		customView.actionButton.isHidden = true
		customView.showMoreIndicator(false)
		customView.state = .empty
	}
	
	/// Reloads the table view,  shows the success view, and shows or hides the footer view depending on
	/// whether there are more results to fetch.
	func showSuccessView(hasMoreResults: Bool) {
		customView.showMoreIndicator(hasMoreResults == true)
		customView.tableView.reloadData()
		customView.state = .success
	}
	
}

// MARK: - Objective-C Action Selectors
fileprivate extension UserListViewController {
	
	/// Invoked by the retry button to retry any retriable action.
	@objc func handleTapOnActionButton() {
		retryController.invoke()
	}
	
	/// Invoked when the refresh control is triggered.
	@objc func handlePullOnRefreshControl() {
//		refreshList()
	}
	
	/// Invoked when reachability changes.
	@objc func handleReachabilityChangedNotification(notification: NSNotification) {
		guard let sender = notification.object as? Reachability,
			sender == Reachability.shared
			else {
				return
		}
		let (networkStatus, requiresConnection) = (sender.currentReachabilityStatus(), sender.connectionRequired())
		switch (networkStatus, requiresConnection) {
		case (.ReachableViaWiFi, false), (.ReachableViaWWAN, false):
			retryController.invoke()
		default:
			break
		}
	}
	
}

// MARK: - Worker Methods
extension UserListViewController {
	
	/// Loads the Core Data stack and proceeds to make the first Core Data fetch.
	func begin() {
		customView.state = .loading
		CoreDataStack.initialize(persistenceType: .onDisk) { (result) in
			DispatchQueue.main.async {
				switch result {
				case .failure(let error):
					self.showFailureView(forError: error)
				case .success(_):
					self.loadCachedResults()
				}
			}
		}
	}
	
	/// Runs the fetch controller to load the cached results. If there are cached objects, they are displayed in a table view.
	/// If there are no objects in the cache, the function proceeds to remotely fetch and locally cache the first batch of users.
	func loadCachedResults() {
		do {
			try runFetchController()
			let objectCount = fetchController.fetchedObjects?.count ?? 0
			if objectCount > 0 {
				showSuccessView(hasMoreResults: true)
			} else {
				let action = {
					self.customView.state = .loading
					self.remoteFetchAndLocalSaveFromZero()
				}
				retryController.set(action: action, name: RetryActionName.remoteFetchAndLocalSaveFromZero.rawValue, parameter: 0)
				action()
			}
		} catch {
			showFailureView(forError: error)
		}
	}
	
	/// Executes a remote fetch and local save for the first batch of users, and modifies view state according to the result.
	func remoteFetchAndLocalSaveFromZero() {
		// Avoid duplicate operations.
		guard isCurrentlyRunningRemoteFetchAndLocalSave(since: 0) == false
			else {
				return
		}
		
		let operation = CombinedService.Users.RemoteFetchAndLocalSave(since: 0, shouldPurgeCache: true) { (operation) in
			guard operation.isCancelled == false,
				let result = operation.result
				else {
					return
			}
			DispatchQueue.main.async {
				switch result {
				case .failure(let error):
					self.showFailureView(forError: error)
					
				case .success(let lastUserID):
					do {
						try self.runFetchController()
						let objectCount = self.fetchController.fetchedObjects?.count ?? 0
						if objectCount > 0 {
							self.showSuccessView(hasMoreResults: lastUserID != nil)
						} else {
							self.showNoUsersView()
						}
						self.retryController.release(name: RetryActionName.remoteFetchAndLocalSaveFromZero.rawValue, parameter: 0)
					} catch {
						self.showFailureView(forError: error)
					}
				}
			}
		}
		queue.addOperation(operation)
	}
	
	/// Executes a remote fetch and local save for the next batch of users. Modifies view state according to the result and the assumption
	/// that the view was already displaying previous batches.
	func remoteFetchAndLocalSaveNextPage() {
		// Get the last user ID and ensure that the same operation isn't run more than once.
		guard let lastUserID = fetchController.fetchedObjects?.last?.id,
			isCurrentlyRunningRemoteFetchAndLocalSave(since: lastUserID) == false
			else {
				return
		}
		
		let intUserID = Int(lastUserID)
		let action = {
			let operation = CombinedService.Users.RemoteFetchAndLocalSave(since: intUserID, shouldPurgeCache: false) { (operation) in
				if operation.isCancelled == false,
					let result = operation.result,
					case .success(let lastUserID) = result {
					DispatchQueue.main.async {
						self.retryController.release(name: "remoteFetchAndLocalSave", parameter: intUserID)
						self.customView.showMoreIndicator(lastUserID != nil)
					}
				}
			}
			self.queue.addOperation(operation)
		}
		retryController.set(action: action, name: "remoteFetchAndLocalSave", parameter: intUserID)
		action()
	}
	
	/// Tells whether there is already a `CombinedService.Users.RemoteFetchAndLocalSave`for the `userID` in the internal queue.
	func isCurrentlyRunningRemoteFetchAndLocalSave(since userID: Int64) -> Bool {
		let userID = Int(userID)
		return queue.operations.contains(where: {
			if let operation = $0 as? CombinedService.Users.RemoteFetchAndLocalSave,
				operation.userID == userID {
				return true
			}
			return false
		})
	}
	
//	func refreshList() {
//		if let ongoingOperation = MiscellaneousQueue.shared.operations.first(where: { $0 is GetUsersOperation }) as? GetUsersOperation,
//			ongoingOperation.userId == 0 {
//			return
//		}
//
//		MiscellaneousQueue.shared.cancelAllOperations()
//		Network.queue.cancelAllOperations()
//		PersistentContainer.queue.cancelAllOperations()
//		deleteFetchedResultsControllerCache()
//
//		let operation = GetUsersOperation(since: 0, shouldPurgeCache: true) { (operation) in
//			DispatchQueue.main.async {
//				self.customView.refreshControl.endRefreshing()
//				guard operation.isCancelled == false,
//					let result = operation.result,
//					case .success(let lastUserID) = result
//					else {
//						return
//				}
//				if lastUserID == nil {
//					self.showNoUsersView()
//				} else {
//					try? self.fetchedResultsController.performFetch()
//					self.customView.showMoreIndicator(true)
//					self.customView.tableView.reloadData()
//				}
//			}
//		}
//		MiscellaneousQueue.shared.addOperation(operation)
//	}
	
}
