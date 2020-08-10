//
//  UserProfileView.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

@IBDesignable class UserProfileView: UIView, BasicLoadableView {
	
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var loadingView: UIActivityIndicatorView!
	var successView: UIView!
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var followersLabel: UILabel!
	@IBOutlet weak var followingLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var noteTextField: UITextField!
	@IBOutlet weak var saveButton: UIButton!
	
	var state: LoadableViewState = .initial {
		didSet {
			updateAppearance(forState: state)
		}
	}
	
	var presenter = DefaultPresenter()
	
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
	
	func setUserProfile(_ userProfile: UserProfile?) {
		presenter.present(userProfile, in: self)
	}
	
}

fileprivate extension UserProfileView {
	
	func setupStructure() {
		let viewFromNib = viewFromOwnedNib()
		addSubviewAndFill(viewFromNib)
		successView = scrollView
		state = .loading
	}
	
}
