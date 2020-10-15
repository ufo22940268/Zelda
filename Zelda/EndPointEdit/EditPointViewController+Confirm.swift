//
//  EditPointViewController+Confirm.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import AppKit
import Combine
import Foundation

extension EndPointEditViewController {
	func saveEndPoint() -> NSManagedObjectID {
		let ep = EndPointEntity(context: context)
		ep.url = url

		for api in apiDataArray.filter({ watchPathsSubject.value.contains($0.0) }) {
			let (path, value) = api
			let apiEntity = ApiEntity(context: context)
			apiEntity.endPoint = ep
			apiEntity.paths = path
			apiEntity.value = value
		}

		try! context.save()
		try! context.parent!.save()
		
		return ep.objectID
	}
}
