//
//  ModelPresenter.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

protocol ModelPresenter {
	
	associatedtype ModelType
	associatedtype ViewType
	
	func present(_ model: ModelType?, in view: ViewType)
	
}
