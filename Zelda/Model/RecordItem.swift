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
		var watchValue: String?

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
	
	var timings: Timings
	
	struct Timings: Decodable {
		var wait: TimeInterval
		var dns: TimeInterval
		var tcp: TimeInterval
		var request: TimeInterval
		var firstByte: TimeInterval
		var download: TimeInterval
		var total: TimeInterval
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

	var format: String {
		split(separator: "\n")
			.map { $0.split(separator: ":") }
			.reduce(into: "") { headers, ar -> Void in
				headers += ar[0].capitalized + ": " + ar[1]
				headers += "\n"
			}
	}
}
