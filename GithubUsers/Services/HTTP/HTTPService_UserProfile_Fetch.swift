//
//  HTTPService_UserProfile_Fetch.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

extension HTTPService.UserProfile {
	
	class Fetch: AsyncOperation<RawUserProfile, Error> {
		
		let username: String
		let urlSession: URLSession
		
		fileprivate var task: URLSessionDataTask?
		
		init(username: String, urlSession: URLSession, completionBlock: OperationCompletionBlock?) {
			self.username = username
			self.urlSession = urlSession
			super.init(completionBlock: completionBlock)
		}
		
		override func cancel() {
			super.cancel()
			task?.cancel()
		}
		
		override func main() {
			do {
				task = try Fetch.execute(username: username, urlSession: urlSession, responseHandler: handleResponse)
			} catch {
				result = .failure(error)
				finish()
			}
		}
		
		func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
			defer {
				self.finish()
			}
			
			if self.isCancelled {
				return
			}
			
			if let error = error {
				self.result = .failure(error)
				return
			}
			
			guard let data = data
				else {
					self.result = .failure(HTTPServiceError.serverReturnedNoData)
					return
			}
			
			if self.isCancelled {
				return
			}
			
			do {
				let result = try JSONDecoder().decode(RawUserProfile.self, from: data)
				self.result = .success(result)
			} catch {
				self.result = .failure(error)
			}
		}
		
		class func makeURL(using username: String) throws -> URL {
			var components = GithubAPI.baseURLComponents
			components.path = "/users/\(username)"
			if let url = components.url {
				return url
			} else {
				throw HTTPServiceError.invalidUrl(components.debugDescription)
			}
		}
		
		@discardableResult
		class func execute(username: String, urlSession: URLSession, responseHandler: ((Data?, URLResponse?, Error?) -> Void)?) throws -> URLSessionDataTask {
			let url = try Fetch.makeURL(using: username)
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = HTTPMethod.get.rawValue
			
			let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
				responseHandler?(data, response, error)
			}
			task.resume()
			return task
		}
		
	}
	
}
