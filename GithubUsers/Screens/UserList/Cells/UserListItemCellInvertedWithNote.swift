//
//  UserListItemCellInvertedWithNote.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/11/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

class UserListItemCellInvertedWithNote: UserListItemCellDefaultWithNote {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		presenter = UserListItemCellPresenter(invertsImageColors: true)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		presenter = UserListItemCellPresenter(invertsImageColors: true)
	}
	
}
