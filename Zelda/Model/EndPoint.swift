//
//  EndPoint.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import CoreData
import Foundation

struct EndPoint: Decodable, Equatable {
	struct WatchField: Decodable {
		var path: String
		var value: String
	}

	var url: String
	var _id: String

	var hasIssue: Bool
	var hasTimeout: Bool

	static func == (lhs: EndPoint, rhs: EndPoint) -> Bool {
		lhs._id == rhs._id
	}
}

struct EndPointReq: Codable {
	struct WatchField: Codable {
		var path: String
		var value: String
	}

	var url: String
	var watchFields: [WatchField]?
}
