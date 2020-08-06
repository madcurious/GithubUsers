//
//  RawUserProfile.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

struct RawUserProfile: Codable {
	
	let avatar_url: String?
	let bio: String?
	let company: String?
	let created_at: String?
	let email: String?
	let followers: Int?
	let following: Int?
	let id: Int?
	let location: String?
	let login: String?
	let name: String?
	let url: String?
	
}
