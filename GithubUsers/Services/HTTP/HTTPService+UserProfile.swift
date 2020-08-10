//
//  HTTPService+UserProfile.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

//extension HTTPService {
//	class UserProfile {
//		
//		/// Creates and runs a data task to get a user's profile based on a username.
//		/// - Parameters:
//		///		- username: The user's usernam.
//		///		- session: The `URLSession` used to create the data task.
//		///		- completion: The completion block.
//		///		- result: The result of the request. Holds a `RawUserProfile` if successful; otherwise holds an `Error`.
//		/// - Throws: An `Error` that occurred during request creation and before the data task is created and run.
//		@discardableResult
//		class func get(username: String, session: URLSession, completion: @escaping (_ result: Result<RawUserProfile, Error>) -> Void) throws -> URLSessionDataTask {
//			var components = GithubAPI.baseURLComponents
//			components.path = "/users/\(username)"
//			guard let url = components.url
//				else {
//					throw HTTPServiceError.invalidUrl(components.debugDescription)
//			}
//			var request = URLRequest(url: url)
//			request.httpMethod = HTTPMethod.get.rawValue
//			
//			let dataTask = session.dataTask(with: request) { (data, response, error) in
//				if let error = error {
//					completion(.failure(error))
//				}
//			}
//			dataTask.resume()
//			return dataTask
//		}
//		
//	}
//}
