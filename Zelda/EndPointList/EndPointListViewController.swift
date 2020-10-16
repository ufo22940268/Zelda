//
//  SideBarContentViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

class EndPointListViewController: NSViewController {
		
	@IBOutlet weak var outlineView: NSOutlineView!
	var cancellables = Set<AnyCancellable>()
	var context = NSManagedObjectContext.main
	var endPoints: [EndPoint] =  [EndPoint(url: "http://wefw.com/22", watchFields: []), EndPoint(url: "http://wefw.com/11", watchFields: [])]

	override func viewDidLoad() {
		NotificationCenter.default.publisher(for: .syncEndPoint)
			.flatMap { notif -> AnyPublisher<Void, ResponseError> in
				let endPointId = (self.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: notif.object as! URL))!
				let endPoint = self.context.object(with: endPointId)
				return BackendAgent.default.upsert(endPoint: endPoint as! EndPointEntity)
			}
			.sink(receiveCompletion: { _ in
			}, receiveValue: {})
			.store(in: &cancellables)
		
		outlineView.expandItem(nil, expandChildren: true)
	}
}
