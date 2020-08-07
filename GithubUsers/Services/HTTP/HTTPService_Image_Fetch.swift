//
//  HTTPService_Image_Fetch.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/7/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import Foundation

extension HTTPService.Image {
	
	class Fetch: AsyncOperation<Data, Error> {
		
		let urlString: String
		let urlSession: URLSession
		var task: URLSessionDataTask?
		
		init(urlString: String, urlSession: URLSession, completion: OperationCompletionBlock?) {
			self.urlString = urlString
			self.urlSession = urlSession
			super.init(completionBlock: completion)
		}
		
		override func cancel() {
			super.cancel()
			task?.cancel()
		}
		
		override func main() {
			guard let url = URL(string: urlString)
				else {
					result = .failure(HTTPServiceError.invalidUrl(urlString))
					finish()
					return
			}
			
			task = Fetch.execute(url: url, urlSession: urlSession, completion: { (result) in
				defer {
					self.finish()
				}
				if self.isCancelled == true {
					return
				}
				self.result = result
			})
		}
		
		/// Downloads an image from a given URL.
		/// - Parameters:
		///		- url: The URL from which to fetch the image.
		///		- session: The `URLSession` image to run the task
		///		- completion: The completion block.
		///		- result: The result of the request. If successful, the image `Data` is returned; otherwise an `Error` is returned.
		/// - Returns: The `URLSessionDataTask` used to run the request.
		@discardableResult
		class func execute(url: URL, urlSession: URLSession, completion: @escaping (Fetch.ResultType) -> Void) -> URLSessionDataTask {
			let request = URLRequest(url: url)
			let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
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
