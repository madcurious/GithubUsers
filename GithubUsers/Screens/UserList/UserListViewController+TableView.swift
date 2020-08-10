//
//  UserListViewController+TableView.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 7/23/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

extension UserListViewController {
	
	enum CellType: String {
		case `default`
		case defaultWithNote
		case inverted
		case invertedWithNote
	}
	
	/// Sets up table view delegation and registered cells.
	func setupTableView() {
		customView.tableView.dataSource = self
		customView.tableView.delegate = self
		customView.tableView.register(UserListItemCellDefault.self, forCellReuseIdentifier: CellType.default.rawValue)
//		customView.tableView.register(UserPreviewCellDefaultWithNote.self, forCellReuseIdentifier: CellType.defaultWithNote.rawValue)
//		customView.tableView.register(UserPreviewCellInverted.self, forCellReuseIdentifier: CellType.inverted.rawValue)
//		customView.tableView.register(UserPreviewCellInvertedWithNote.self, forCellReuseIdentifier: CellType.invertedWithNote.rawValue)
	}
	
	func cellType(at indexPath: IndexPath) -> CellType {
		return .default
//		let hasNote = fetchedResultsController.object(at: indexPath).hasNote
//		let isInverted = (indexPath.row + 1) % 4 == 0
//		switch (hasNote, isInverted) {
//		case (false, false):
//			return .default
//		case (false, true):
//			return .inverted
//		case (true, false):
//			return .defaultWithNote
//		default:
//			return .invertedWithNote
//		}
	}
	
}

extension UserListViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchController?.sections,
			let firstSection = sections.first {
			return firstSection.numberOfObjects
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let numberOfObjects = fetchController?.fetchedObjects?.count,
			indexPath.row == numberOfObjects - fetchThreshold {
			fetchAndSaveNextPage()
		}
		
		let type = cellType(at: indexPath)
		let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue, for: indexPath)
		if let itemCell = cell as? UserListItemCell,
			let item = fetchController?.object(at: indexPath) {
			itemCell.setUserListItem(item)
		}
		return cell
	}
	
}

extension UserListViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedIndexPath = indexPath
		performSegue(withIdentifier: "kSegueToUserProfile", sender: self)
	}
	
}

