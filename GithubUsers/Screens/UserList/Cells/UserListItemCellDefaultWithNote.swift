//
//  UserListItemCellDefaultWithNote.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

@IBDesignable class UserListItemCellDefaultWithNote: UITableViewCell, UserListItemCell {
	
	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	
	var presenter = UserListItemCellPresenter(invertsImageColors: false)
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
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
	
	func setUserListItem(_ model: UserListItem?) {
		presenter.present(model, in: self)
	}
	
}

fileprivate extension UserListItemCellDefaultWithNote {
	
	func setupStructure() {
		let viewFromNib = viewFromOwnedNib(named: String(describing: UserListItemCellDefaultWithNote.self))
		contentView.addSubviewAndFill(viewFromNib)
		iconImageView.image = UIImage.template(named: "iconNote")
		iconImageView.tintColor = .systemGray2
	}
	
}
