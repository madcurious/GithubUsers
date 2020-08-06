//
//  Test_HTTPService_UserList.swift
//  GithubUsersTests
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import XCTest
@testable import GithubUsers

class Test_HTTPService_UserList: XCTestCase {
	
	var session: URLSession!
	
	override func setUp() {
		session = URLSession(configuration: .default)
	}
	
	/// Tests that user list requests should succeed with an empty array even if the Github API returns an empty array.
	/// As of date, there are about 69M Github users, so using 100M as a `since` parameter returns an empty array.
	func test_returnedEmptyArray_requestShouldSucceedWithEmptyArray() {
		let xp = expectation(description: #function)
		do {
			try HTTPService.UserList.get(lastUserID: 100_000_000, session: session) { (result) in
				xp.fulfill()
				switch result {
				case .failure(let error):
					XCTAssertNil(error)
				case .success(let items):
					XCTAssertTrue(items.isEmpty)
				}
			}
		} catch {
			XCTAssertNil(error)
		}
		wait(for: [xp], timeout: 30)
	}
	
}
