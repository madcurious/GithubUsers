//
//  UserListItemCellInverted.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/11/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

class UserListItemCellInverted: UserListItemCellDefault {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		presenter = UserListItemCellPresenter(invertsImageColors: true)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		presenter = UserListItemCellPresenter(invertsImageColors: true)
	}
	
}
