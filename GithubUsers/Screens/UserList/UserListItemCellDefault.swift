//
//  UserListItemCellDefault.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

class UserListItemCellDefault: UITableViewCell, UserListItemCell {
	
	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
	var presenter = DefaultPresenter()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupStructure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupStructure()
	}
	
	func setupStructure() {
		let viewFromNib = viewFromOwnedNib(named: String(describing: type(of: self)))
		contentView.addSubviewAndFill(viewFromNib)
	}
	
	func setUserListItem(_ model: UserListItem?) {
		presenter.present(model, in: self)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		presenter.present(nil, in: self)
	}
	
}
