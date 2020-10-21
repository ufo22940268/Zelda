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

		func toApiEntity(context: NSManagedObjectContext, ee: EndPointEntity) -> ApiEntity {
			let ae = ApiEntity(context: context)
			ae.endPoint = ee
			ae.watchValue = value
			ae.paths = path
			return ae
		}
	}

	struct WarningCount: Decodable {
		var issue: Int
		var duration: Int
	}

	var url: String
//	var watchFields: [WatchField]?
	var _id: String

	var warningCount: WarningCount

	var hasIssue: Bool {
		warningCount.issue > 0
	}

	var requestTimeout: Bool {
		warningCount.duration > 0
	}

	static func == (lhs: EndPoint, rhs: EndPoint) -> Bool {
		lhs._id == rhs._id
	}
}
