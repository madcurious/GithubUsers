//
//  DateFormatter.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

class DateFormatter {
	
	static let shared: ISO8601DateFormatter = {
		var formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
		return formatter
	}()
	
}
