//
//  Test_HTTPService_Users_Fetch.swift
//  GithubUsersTests
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

import XCTest
import CoreData
@testable import GithubUsers

class Test_HTTPService_Users_Fetch: XCTestCase {
	
	/// Tests that user list requests should succeed even if the Github API returns an empty array because there are no more users.
	/// As of date, there are about 69 million Github users, so using 100 million as a `since` parameter returns an empty array.
	func test_returnedEmptyArray_requestShouldSucceedWithEmptyArray() {
		let urlSession = URLSession(configuration: .default)
		let xp = expectation(description: #function)
		do {
			try HTTPService.Users.Fetch.execute(
				since: 100_000_000,
				urlSession: urlSession,
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
	
	/// Tests that fetch requests returning user objects with missing keys should succeed anyway, but saving them to Core Data should fail.
	func test_returnedInvalidUsers_requestShouldSucceedButSaveShouldFail() {
		class TestURLProtocol: MockURLProtocol<[RawUserListItem]> {
			override func makeResponseBody() -> [RawUserListItem] {
				return [
					RawUserListItem(avatar_url: "https://avatars0.githubusercontent.com/u/1?v=4", id: 1, login: nil), // invalid
					RawUserListItem(avatar_url: "https://avatars0.githubusercontent.com/u/2?v=4", id: 2, login: "defunkt"),
					RawUserListItem(avatar_url: "https://avatars0.githubusercontent.com/u/3?v=4", id: 3, login: "pjhyett")
				]
			}
		}
		
		// Assign a mock URLProtocol class to avoid actually fetching from network and to return our desired dummy data.
		let config = URLSessionConfiguration.default
		config.protocolClasses = [TestURLProtocol.self]
		let urlSession = URLSession(configuration: config)
		let queue = OperationQueue()
		
		// First part of the test: fetching from network.
		var rawItems: [RawUserListItem]!
		let fetchOperation = HTTPService.Users.Fetch(since: 0, urlSession: urlSession, completion: nil)
		queue.addOperations([fetchOperation], waitUntilFinished: true)
		
		guard let fetchResult = fetchOperation.result
			else {
				return
		}
		switch fetchResult {
			case .failure(let error):
				XCTAssertNil(error)
			case .success(let items):
				XCTAssertTrue(items.compactMap({ $0.id }) == [1, 2, 3])
				XCTAssertTrue(items.first(where: { $0.id == 1 })?.login == nil)
				rawItems = items
		}
		
		// Second part of the test: saving to Core Data.
		let xp2 = expectation(description: #function)
		let objects = rawItems.map({ UserListItem.makeObjectDictionary(from: $0) })
		let persistentContainer = CoreDataStack.makeNew(persistenceType: .onDisk)
		persistentContainer.loadPersistentStores { (_, error) in
			XCTAssertNil(error)
			xp2.fulfill()

			let saveOperation = CoreDataService.Users.Save(objects: objects, persistentContainer: persistentContainer, completion: nil)
			queue.addOperations([saveOperation], waitUntilFinished: true)
			guard let result = saveOperation.result
				else {
					return
			}
			switch result {
			case .failure(let error):
				XCTAssertNotNil(error)
				let failedKey = (error as NSError).userInfo[NSValidationKeyErrorKey] as? String
				XCTAssertNotNil(failedKey)
				XCTAssertEqual(failedKey, "username")
			case .success(_):
				XCTFail("Save should not succeed.")
			}
		}
		wait(for: [xp2], timeout: 30)
	}
	
}
