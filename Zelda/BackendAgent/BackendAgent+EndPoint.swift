//
//  BackendAgent+EndPoint.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Foundation
import Combine
import SwiftyJSON
import CoreData

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
	
	func syncFromServer(context: NSManagedObjectContext) -> AnyPublisher<Void, ResponseError> {
		get(endPoint: "/endpoint/sync/list")
			.parseArrayObjects(to: EndPoint.self)
			.receive(on: DispatchQueue.main)
			.map { (endPoints: [EndPoint]) in
				let req = EndPointEntity.fetchRequest() as NSFetchRequest<EndPointEntity>
				req.predicate = NSPredicate(format: "url IN %@", endPoints.map { $0.url })
				if let exists: [EndPointEntity] = try? context.fetch(req) {
					let newEndPointEntities = endPoints.filter { e in
						!exists.map { $0.url! }.contains(e.url)
					}

					_ = newEndPointEntities.map {
						let _ = $0.toEntity(context: context)
					}
				}
				try! context.save()
			}
			.eraseToAnyPublisher()
	}
}


extension JSONDecoder {
	static var backendDecoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
		return decoder
	}
}

struct JSONFragment {
	var text: String
	var hightlight = false
}

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	formatter.calendar = Calendar(identifier: .iso8601)
	formatter.timeZone = TimeZone(secondsFromGMT: 0)
	formatter.locale = Locale(identifier: "en_US_POSIX")
	return formatter
  }()
}


