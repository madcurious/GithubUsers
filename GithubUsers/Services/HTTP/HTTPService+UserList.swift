//
//  HTTPService+UserList.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

extension HTTPService {
	class UserList {
		
		/// Creates and runs a data task to get a list of users since a given user ID.
		/// - Parameters:
		///		- lastUserID: The user ID that serves as a pagination reference.
		///		- session: The `URLSession` that will coordinate the data task.
		///		- completion: The completion block.
		///		- result: The result of the request. Holds an array of `RawUserListItem` if successful; otherwise holds an `Error`.
		///	- Throws: An `Error` that was thrown during request creation and before the data task is created and run.
		@discardableResult
		class func get(lastUserID: Int, session: URLSession, completion: @escaping ((_ result: Result<[RawUserListItem], Error>) -> Void)) throws -> URLSessionDataTask {
			var components = GithubAPI.baseURLComponents
			components.path = "/users"
			components.queryItems = [URLQueryItem(name: "since", value: "\(lastUserID)")]
			
			guard let url = components.url
				else {
					throw HTTPServiceError.invalidUrl(components.debugDescription)
			}
			var request = URLRequest(url: url)
			request.httpMethod = HTTPMethod.get.rawValue
			
			let dataTask = session.dataTask(with: request) { (data, response, error) in
				if let error = error {
					completion(.failure(error))
					return
				}
				guard let data = data
					else {
						completion(.failure(HTTPServiceError.serverReturnedNoData))
						return
				}
				do {
					let result = try JSONDecoder().decode([RawUserListItem].self, from: data)
					completion(.success(result))
				} catch {
					completion(.failure(error))
				}
			}
			dataTask.resume()
			return dataTask
		}
		
	}
}
