//
//  HTTPService+Image.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

extension HTTPService {
	class Image {
		
		/// Downloads an image from a given URL.
		/// - Parameters:
		///		- url: The URL from which to fetch the image.
		///		- session: The `URLSession` image to run the task
		///		- completion: The completion block.
		///		- result: The result of the request. If successful, the image `Data` is returned; otherwise an `Error` is returned.
		/// - Returns: The `URLSessionDataTask` used to run the request.
		@discardableResult
		class func get(from url: URL, session: URLSession, completion: @escaping (_ result: Result<Data, Swift.Error>) -> Void) -> URLSessionDataTask {
			let request = URLRequest(url: url)
			let dataTask = session.dataTask(with: request) { (data, response, error) in
				if let error = error {
					completion(.failure(error))
					return
				}
				if let data = data {
					completion(.success(data))
				} else {
					completion(.failure(HTTPServiceError.serverReturnedNoData))
				}
			}
			dataTask.resume()
			return dataTask
		}
		
	}
}
