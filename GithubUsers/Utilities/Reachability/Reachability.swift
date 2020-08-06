//
//  Reachability.swift
//  TawkToTest
//
//  Created by Matthew Quiros on 7/25/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

extension Reachability {
	
	static let shared = Reachability.forInternetConnection()!
	
}
