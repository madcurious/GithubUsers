//
//  UserListItemCell.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

protocol UserListItemCell: UITableViewCell {
	
	func setUserListItem(_ model: UserListItem?)
	
}
