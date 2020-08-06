//
//  RawUserListItem.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

struct RawUserListItem: Codable {
	
	let avatar_url: String?
	let id: Int?
	let login: String?
	
}
