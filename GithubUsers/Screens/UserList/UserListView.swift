//
//  UserListView.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 7/26/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

@IBDesignable class UserListView: UIView, BasicLoadableView {
	
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var loadingView: UIActivityIndicatorView!
	@IBOutlet weak var tableView: UITableView!
	
	var successView: UIView!
	let refreshControl = UIRefreshControl(frame: .zero)
	let footerView = UserListFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
	
	var state: LoadableViewState = .initial {
		didSet {
			updateAppearance(forState: state)
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupStructure()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupStructure()
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupStructure()
		state = .success
	}
	
	/// Shows or hides the spinning indicator at the bottom of the table view, which suggests that there's more content.
	func showMoreIndicator(_ shouldShow: Bool) {
		if shouldShow {
			if tableView.tableFooterView == nil {
				tableView.tableFooterView = footerView
				footerView.loadingView.startAnimating()
			}
		} else {
			tableView.tableFooterView = nil
			footerView.loadingView.stopAnimating()
		}
	}
	
}

fileprivate extension UserListView {
	
	func setupStructure() {
		let viewFromNib = viewFromOwnedNib()
		addSubviewAndFill(viewFromNib)
		tableView.refreshControl = refreshControl
		successView = tableView
	}
	
}
