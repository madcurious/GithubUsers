//
//  BasicLoadableView.swift
//  iOSToolkit
//
//  Created by Matthew Quiros on 19/10/2017.
//  Copyright © 2017 Matthew Quiros. All rights reserved.
//

import UIKit

protocol BasicLoadableView: LoadableView {
	
	var actionButton: UIControl! { get set }
	var informationContainerView: UIView! { get set }
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
			successView.isHidden = true
			informationContainerView.isHidden = true

		case .loading:
			loadingView.startAnimating()
			loadingView.isHidden = false
			successView.isHidden = true
			informationContainerView.isHidden = true

		case .empty:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			successView.isHidden = true
			informationContainerView.isHidden = false

		case .success:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			successView.isHidden = false
			informationLabel.text = nil
			informationContainerView.isHidden = true

		case .failure:
			loadingView.stopAnimating()
			loadingView.isHidden = true
			successView.isHidden = true
			informationContainerView.isHidden = false
		}
	}
	
}
