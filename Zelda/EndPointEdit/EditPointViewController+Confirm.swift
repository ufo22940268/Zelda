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
	func saveEndPoint() {
		let ep = EndPointEntity(context: context)
		ep.url = urlSubject.value

		for api in apiDataArray.filter({ watchPaths.contains($0.0) }) {
			let (path, value) = api
			let apiEntity = ApiEntity(context: context)
			apiEntity.endPoint = ep
			apiEntity.paths = path
			apiEntity.value = value
			apiEntity.watch = true
		}

		try! context.save()
		try! context.parent!.save()
	}
}
