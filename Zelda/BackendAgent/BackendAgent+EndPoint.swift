//
//  BackendAgent+EndPoint.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Combine
import CoreData
import Foundation
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
						_ = $0.toEntity(context: context)
					}
				}
				try! context.save()
			}
			.eraseToAnyPublisher()
	}

	func listScanLogInSpan(endPoint: String) -> AnyPublisher<ScanLogInTimeSpan, ResponseError> {
		get(endPoint: "/scanlog/list/span/\(endPoint)")
			.parseObject(to: ScanLogInTimeSpan.self)
			.eraseToAnyPublisher()
	}

	func getRecordItem(scanLogId: String) -> AnyPublisher<RecordItem, ResponseError> {
		get(endPoint: "/scanlog/\(scanLogId)")
			.parseObject(to: RecordItem.self)
			.eraseToAnyPublisher()
	}

	func deleteEndPoint(by url: String) -> AnyPublisher<Void, ResponseError> {
		post(endPoint: "/endpoint/delete", data: ["url": url])
			.eraseToVoidAnyPublisher()
	}
}

