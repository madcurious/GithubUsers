//
//  GithubAPI.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

class GithubAPI {
	
	static let baseURLComponents: URLComponents = {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.github.com"
		return components
	}()
	
}
