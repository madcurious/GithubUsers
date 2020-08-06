//
//  Test_HTTPService_Users_Fetch.swift
//  GithubUsersTests
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

import XCTest
@testable import GithubUsers

class Test_HTTPService_Users_Fetch: XCTestCase {
	
	var session: URLSession!
	
	override func setUp() {
		session = URLSession(configuration: .default)
	}
	
	/// Tests that user list requests should succeed even if the Github API returns an empty array because there are no more users.
	/// As of date, there are about 69 million Github users, so using 100 million as a `since` parameter returns an empty array.
	func test_returnedEmptyArray_requestShouldSucceedWithEmptyArray() {
		let xp = expectation(description: #function)
		do {
			try HTTPService.Users.Fetch.execute(
				since: 100_000_000,
				urlSession: session,
				responseHandler: HTTPService.Users.Fetch.makeDefaultResponseHandler { (result) in
					xp.fulfill()
					switch result {
					case .failure(let error):
						XCTAssertNil(error)
					case .success(let items):
						XCTAssertTrue(items.isEmpty)
					}
			})
		} catch {
			XCTAssertNil(error)
		}
		wait(for: [xp], timeout: 30)
	}
	
}
