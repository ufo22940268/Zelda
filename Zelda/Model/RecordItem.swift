//
//  RecordItem.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/20.
//

import Foundation

typealias StatusCode = Int
typealias HttpHeader = String

struct RecordItem: Decodable {
	struct WatchField: Decodable, Identifiable {
		var path: String
		var value: String
		var watchValue: String

		var id: String {
			path
		}

		var match: Bool {
			return value == watchValue
		}
	}

	var duration: TimeInterval
	var statusCode: Int
	var time: Date
	var requestHeader: HttpHeader
	var responseHeader: HttpHeader
	var responseBody: String
	var fields: [WatchField]

	var okFields: [WatchField] {
		fields.filter { $0.match }
	}

	var failedFields: [WatchField] {
		fields.filter { !$0.match }
	}
}

extension HttpHeader {
	var dict: [String: String] {
		split(separator: "\n")
			.map { $0.split(separator: ":") }
			.reduce(into: [String: String]()) { headers, ar in
				headers[String(ar[0])] = String(ar[1])
			}
	}
}
