//
//  EndPoint.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import CoreData
import Foundation

struct EndPoint: Codable {
	struct WatchField: Codable {
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

	var url: String
	var watchFields: [WatchField]?
	var _id: String

	func toEntity(context: NSManagedObjectContext) -> EndPointEntity {
		let ee = EndPointEntity(context: context)
		ee.url = url
		ee.needReload = true
		ee.id = _id

		if let watchFields = watchFields {
			for field in watchFields {
				ee.addToApi(field.toApiEntity(context: context, ee: ee))
			}
		}

		return ee
	}
}
