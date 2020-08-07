//
//  UserListViewController+FetchedResultsController.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 7/26/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

extension UserListViewController {
	
	static let cacheName = "UserList"
	
	func runFetchController() throws {
		if fetchController == nil {
			fetchController = UserListViewController.makeFetchController()
			fetchController.delegate = self
		} else {
			// Delete the cache.
			NSFetchedResultsController<UserListItem>.deleteCache(withName: UserListViewController.cacheName)
		}
		CoreDataStack.shared.viewContext.reset()
		try fetchController.performFetch()
	}
	
	class func makeFetchController() -> NSFetchedResultsController<UserListItem> {
		let request: NSFetchRequest<UserListItem> = UserListItem.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(key: #keyPath(UserListItem.id), ascending: true)]
		let controller = NSFetchedResultsController(fetchRequest: request,
																								managedObjectContext: CoreDataStack.shared.viewContext,
																								sectionNameKeyPath: nil,
																								cacheName: cacheName)
		return controller
	}
	
}

// MARK: - NSFetchedResultsControllerDelegate
extension UserListViewController: NSFetchedResultsControllerDelegate {
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		customView.tableView.reloadData()
	}
	
}
