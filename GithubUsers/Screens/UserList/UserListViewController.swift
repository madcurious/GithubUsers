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
	
	enum RetryID {
		case fetchAndSaveInitial
		case fetchAndSaveNextPageSince(_ userID: Int)
		case refresh
		func toString() -> String {
			switch self {
			case .fetchAndSaveInitial:
				return "\(UserListViewController.self).fetchAndSaveInitial"
			case .fetchAndSaveNextPageSince(let userID):
				return "\(UserListViewController.self).fetchAndSaveNextPageSince.\(userID)"
			case .refresh:
				return "\(UserListViewController.self).refresh"
			}
		}
	}
	
	/// The main view, set in Main.storyboard.
	@IBOutlet var customView: UserListView!
	
	/// The `NSFetchedResultsController` that provides the list data.
	var fetchController: NSFetchedResultsController<UserListItem>!
	
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
	func showFailureView(error: Error) {
		customView.informationLabel.text = error.localizedDescription
		customView.showMoreIndicator(false)
		customView.state = .failure
	}
	
	/// Shows the view for when there are no Github users.
	func showNoUsersView() {
		customView.informationLabel.text = "There are no Github users."
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
	
	/// Invoked when the refresh control is triggered.
	@objc func handlePullOnRefreshControl() {
		if customView.state != .success {
			customView.refreshControl.endRefreshing()
			return
		}
		refresh()
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
					self.showFailureView(error: error)
				case .success(_):
					self.loadSavedResults()
				}
			}
		}
	}
	
	/// Runs the fetch controller to load the saved results. If there are saved objects, they are displayed in a table view.
	/// If there are no objects saved in the cache, the function proceeds to remotely fetch and locally cache the first batch of users.
	func loadSavedResults() {
		do {
			try runFetchController()
			let objectCount = fetchController.fetchedObjects?.count ?? 0
			if objectCount > 0 {
				showSuccessView(hasMoreResults: true)
			} else {
				makeInitialFetchAndSave()
			}
		} catch {
			showFailureView(error: error)
		}
	}
	
	/// Executes the very first fetch-and-save in the lifetime of the app.
	func makeInitialFetchAndSave() {
		// Avoid duplicate operations.
		guard isCurrentlyRunningFetchAndSave(since: 0) == false
			else {
				return
		}
		
		let operation = CombinedService.Users.FetchAndSave(since: 0, shouldPurgeCache: true) { (operation) in
			guard operation.isCancelled == false,
				let result = operation.result
				else {
					return
			}
			DispatchQueue.main.async {
				switch result {
				case .failure(let error):
					RetryController.shared.mark(block: self.makeInitialFetchAndSave, identifier: RetryID.fetchAndSaveInitial.toString())
					self.showFailureView(error: error)
					
				case .success(let lastUserID):
					do {
						try self.runFetchController()
						let objectCount = self.fetchController.fetchedObjects?.count ?? 0
						if objectCount > 0 {
							self.showSuccessView(hasMoreResults: lastUserID != nil)
						} else {
							self.showNoUsersView()
						}
					} catch {
						self.showFailureView(error: error)
					}
				}
			}
		}
		
		self.customView.state = .loading
		queue.addOperation(operation)
	}
	
	/// Executes a remote fetch and local save for the next batch of users. Modifies view state according to the result and the assumption
	/// that the view was already displaying previous batches.
	func fetchAndSaveNextPage() {
		// Get the last user ID and ensure that the same operation isn't run more than once.
		guard let lastUserID = fetchController.fetchedObjects?.last?.id,
			isCurrentlyRunningFetchAndSave(since: lastUserID) == false
			else {
				return
		}
		
		let intUserID = Int(lastUserID)
		let operation = CombinedService.Users.FetchAndSave(since: intUserID, shouldPurgeCache: false) { (operation) in
			guard operation.isCancelled == false,
				let result = operation.result,
				case .success(let lastUserID) = result
				else {
					RetryController.shared.mark(block: self.fetchAndSaveNextPage, identifier: RetryID.fetchAndSaveNextPageSince(intUserID).toString())
					return
			}
			DispatchQueue.main.async {
				if lastUserID == nil {
					self.customView.showMoreIndicator(false)
					return
				}
				try? self.runFetchController() // ignore errors
				self.customView.tableView.reloadData()
				self.customView.showMoreIndicator(lastUserID != nil)
			}
		}
		self.queue.addOperation(operation)
	}
	
	/// Tells whether there is already a `CombinedService.Users.RemoteFetchAndLocalSave`for the `userID` in the internal queue.
	func isCurrentlyRunningFetchAndSave(since userID: Int64) -> Bool {
		let userID = Int(userID)
		return queue.operations.contains(where: { ($0 as? CombinedService.Users.FetchAndSave)?.userID == userID })
	}
	
	func refresh() {
		if isCurrentlyRunningFetchAndSave(since: 0) {
			return
		}
		
		Queues.http.cancelAllOperations()
		Queues.coreData.cancelAllOperations()
		Queues.images.cancelAllOperations()
		
		let operation = CombinedService.Users.FetchAndSave(since: 0, shouldPurgeCache: true) { (operation) in
			DispatchQueue.main.async {
				self.customView.refreshControl.endRefreshing()
				guard operation.isCancelled == false,
					let result = operation.result,
					case .success(let lastUserID) = result
					else {
						return
				}
				RetryController.shared.reset() // clear all retry actions
				try? self.runFetchController() // ignore errors
				self.customView.tableView.reloadData()
				self.customView.showMoreIndicator(lastUserID != nil)
			}
		}
		queue.addOperation(operation)
	}
	
}
