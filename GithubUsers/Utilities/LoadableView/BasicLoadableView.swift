//
//  BasicLoadableView.swift
//  iOSToolkit
//
//  Created by Matthew Quiros on 19/10/2017.
//  Copyright © 2017 Matthew Quiros. All rights reserved.
//

import UIKit

protocol BasicLoadableView: LoadableView {
	
	var informationLabel: UILabel! { get set }
	var loadingView: UIActivityIndicatorView! { get set }
	var successView: UIView! { get set }
	
	func updateAppearance(forState state: LoadableViewState)
	
}

extension BasicLoadableView {
	
	func updateAppearance(forState state: LoadableViewState) {
		switch state {
		case .initial:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			informationLabel.isHidden = true
			successView.isHidden = true

		case .loading:
			loadingView.startAnimating()
			loadingView.isHidden = false
			informationLabel.isHidden = true
			successView.isHidden = true

		case .empty:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			informationLabel.isHidden = false
			successView.isHidden = true

		case .success:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			informationLabel.isHidden = true
			successView.isHidden = false

		case .failure:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			informationLabel.isHidden = false
			successView.isHidden = true
		}
	}
	
}
