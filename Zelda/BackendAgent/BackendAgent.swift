//
//  BackendAgent.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Combine
import Foundation
import SwiftyJSON

struct LoginInfo {
	var username: String
	var appleUserId: String
}

typealias Response = JSON

extension URL {
	func appending(_ queryItem: String, value: String?) -> URL {
		guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

		// Create array of existing query items
		var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

		// Create query item
		let queryItem = URLQueryItem(name: queryItem, value: value)

		// Append the new query item in the existing query items array
		queryItems.append(queryItem)

		// Append updated query items array in the url component object
		urlComponents.queryItems = queryItems

		// Returns the url from new url components
		return urlComponents.url!
	}
}

extension Publisher where Output == URLSession.DataTaskPublisher.Output, Failure == URLSession.DataTaskPublisher.Failure {
	func convertToJSON() -> AnyPublisher<Response, ResponseError> {
		return tryMap { (data, _) throws -> JSON in
			if let json = try? JSON(data: data) {
				if json["ok"].bool == true {
					return json
				}
				throw ResponseError(json: json)
			}
			throw ResponseError.parseJSONError
		}
		.mapError { (e) -> ResponseError in
			if let e = e as? ResponseError {
				return e
			} else {
				return ResponseError(error: e)
			}
		}
		.eraseToAnyPublisher()
	}
}

class BackendAgent {
	struct RequestOptions: OptionSet {
		static let login = RequestOptions(rawValue: 1 << 0)

		let rawValue: Int
	}

	static let `default` = BackendAgent()
	static let backendDomain = "http://biubiubiu.hopto.org:3000"

	var loginInfo: LoginInfo! {
		return LoginInfo(username: "mac", appleUserId: "simulator_device_token")
	}

	func get(endPoint: String, query: [String: Any] = [:], options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
		var url = (URL(string: Self.backendDomain)!.appendingPathComponent(endPoint))
		url = url.appending("token", value: loginInfo!.appleUserId)
		for (k, v) in query {
			url = url.appending(k, value: String(describing: v))
		}
		var req = URLRequest(url: url)
		req.httpMethod = "GET"
		return URLSession.shared.dataTaskPublisher(for: req)
			.convertToJSON()
			.handleEvents(receiveCompletion: { completion in
				if case .failure(let e) = completion {
					print("Http Error", e)
				}
			})
			.eraseToAnyPublisher()
	}

	func post(endPoint: String, data: [String: Any] = [:], options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
		try! post(endPoint: endPoint, data: try JSONSerialization.data(withJSONObject: data, options: []), options: options)
	}

	func post(endPoint: String, data: JSON, options: RequestOptions = []) -> AnyPublisher<Response, ResponseError> {
		try! post(endPoint: endPoint, data: try data.rawData(), options: options)
	}

	func post(endPoint: String, data: Data?, options: RequestOptions = []) throws -> AnyPublisher<Response, ResponseError> {
		var url = (URL(string: Self.backendDomain)?.appendingPathComponent(endPoint))!
		url = url.appending("token", value: loginInfo!.appleUserId)
		var req = URLRequest(url: url)
		req.httpMethod = "POST"
		if let data = data {
			req.httpBody = data
		}
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")

		if !options.contains(.login) {
			req.setValue(loginInfo!.appleUserId, forHTTPHeaderField: "apple-user-id")
		}

		return URLSession.shared.dataTaskPublisher(for: req)
			.convertToJSON()
			.handleEvents(receiveCompletion: { completion in
				if case .failure(let e) = completion {
					print("Http Error", e)
				}
			})
			.eraseToAnyPublisher()
	}
}
