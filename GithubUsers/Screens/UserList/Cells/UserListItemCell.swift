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
	
	var avatarImageView: UIImageView! { get set }
	var headerLabel: UILabel! { get set }
	var detailLabel: UILabel! { get set }
	
	func setUserListItem(_ model: UserListItem?)
	
}
