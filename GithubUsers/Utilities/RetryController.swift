//
//  RetryController.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/6/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

class RetryController {
	
	fileprivate var action: (() -> Void)?
	fileprivate var name: String?
	fileprivate var parameter: Int?
	
	var hasRetriableAction: Bool {
		return action != nil
	}
	
	/// Sets the action as retriable.
	/// - Parameters:
	///		- action: The code to be retried.
	///		- name: A string identifier for the action.
	///		- parameter: An integer identifier for the action. Normally, this is an argument to the passed to the action that can
	///				distinguish multiple invocations of it from each other.
	func set(action: @escaping () -> Void, name: String, parameter: Int?) {
		self.action = action
		self.name = name
		self.parameter = parameter
	}
	
	/// Forgets the currently set action if the name and parameter correspond to previous settings.
	func release(name: String, parameter: Int?) {
		if self.name == name && self.parameter == parameter {
			action = nil
			self.name = nil
			self.parameter = nil
		}
	}
	
	func invoke() {
		action?()
	}
	
}
