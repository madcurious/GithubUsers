//
//  UserListFooterView.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 7/26/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

@IBDesignable class UserListFooterView: UITableViewHeaderFooterView {
	
	@IBOutlet weak var loadingView: UIActivityIndicatorView!
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setupStructure()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupStructure()
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupStructure()
	}
	
}

fileprivate extension UserListFooterView {
	
	func setupStructure() {
		let viewFromNib = viewFromOwnedNib()
		addSubviewAndFill(viewFromNib)
		
		if #available(iOS 13, *) {
			loadingView.style = .medium
		}
	}
	
}
