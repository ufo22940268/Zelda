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
	
	func listScanLogInSpan(endPoint: String) -> AnyPublisher<ScanLogInTimeSpan, ResponseError> {
		Just(testScanLogs)
			.setFailureType(to: ResponseError.self)
			.eraseToAnyPublisher()
	}
}
