//
//  MockURLProtocol.swift
//  GithubUsersTests
//
//  Created by Matthew Quiros on 8/11/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

class MockURLProtocol<ResponseBodyType: Codable>: URLProtocol {
	
	func makeResponseBody() -> ResponseBodyType {
		fatalError("Developer must override")
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override func startLoading() {
		guard let client = client
			else {
				return
		}
		let body = makeResponseBody()
		let data = try! JSONEncoder().encode(body)
		client.urlProtocol(self, didLoad: data)
		client.urlProtocolDidFinishLoading(self)
	}
	
	override func stopLoading() { }
	
}
