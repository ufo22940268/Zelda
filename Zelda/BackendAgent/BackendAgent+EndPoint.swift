//
//  BackendAgent+EndPoint.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Foundation
import Combine
import SwiftyJSON

extension BackendAgent {
	func upsert(endPoint: EndPointEntity) -> AnyPublisher<Void, ResponseError> {
		var json = JSON()
		json["url"].string = endPoint.url!
		if let apis = endPoint.api?.allObjects.map({ $0 as! ApiEntity }) {
			json["watchFields"].arrayObject = apis.map { api in
				["value": api.watchValue, "path": api.paths]
			}
		}
		return post(endPoint: "/endpoint/upsert", data: json)
			.map { _ in () }
			.eraseToAnyPublisher()
	}
}
