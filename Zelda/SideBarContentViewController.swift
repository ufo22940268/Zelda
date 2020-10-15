//
//  SideBarContentViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

class SideBarContentViewController: NSViewController {
	var cancellables = Set<AnyCancellable>()
	var context = NSManagedObjectContext.main

	override func viewDidLoad() {
		NotificationCenter.default.publisher(for: .syncEndPoint)
			.flatMap { notif -> AnyPublisher<Void, ResponseError> in
				let endPointId = notif.object as! NSManagedObjectID
				let endPoint = self.context.object(with: endPointId)
				return BackendAgent.default.upsert(endPoint: endPoint as! EndPointEntity)
			}
			.sink(receiveCompletion: { _ in
			}, receiveValue: {})
			.store(in: &cancellables)
	}
}
