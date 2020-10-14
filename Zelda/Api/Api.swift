//
//  URL.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import Foundation
import SwiftyJSON

struct ApiHelper {}

extension URLResponse {
	var ok: Bool {
		if let res = self as? HTTPURLResponse, (200 ... 299).contains(res.statusCode) {
			return true
		} else {
			return false
		}
	}
}

struct ResponseError: Error {
	// MARK: Lifecycle

	internal init(json: JSON? = nil) {
		self.json = json
	}

	internal init(error: Error) {
		self.error = error
	}

	internal init(message: String) {
		self.message = message
	}

	// MARK: Internal

	static let parseError = ResponseError(message: "parse_error")
	static let parseJSONError = ResponseError(message: "parse_json_error")
	static let notLogin = ResponseError(message: "not_login")

	var json: JSON?
	var error: Error?
	var message: String?
}
