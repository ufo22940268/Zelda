//
//  SideBarContentViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

class EndPointListViewController: NSViewController {
	@IBOutlet var endPointListView: NSOutlineView!
	var cancellables = Set<AnyCancellable>()
	var context = NSManagedObjectContext.main
	var endPoints: [EndPoint] = [] {
		didSet {
			endPointListView.reloadData()
			self.endPointListView.reloadData()
			self.endPointListView.selectRowIndexes(IndexSet([1]), byExtendingSelection: true)
			self.endPointListView.expandItem(nil, expandChildren: true)
		}
	}
	var syncSubject = PassthroughSubject<Void, Never>()
	var deleteEndPointSubject = PassthroughSubject<EndPoint, Never>()
	var detailVC: EndPointDetailTabViewController!
	var type: SideBarItem!

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.publisher(for: .syncEndPoint)
			.flatMap { notif -> AnyPublisher<Void, ResponseError> in
				let endPointId = (self.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: notif.object as! URL))!
				let endPoint = self.context.object(with: endPointId)
				return BackendAgent.default.upsert(endPoint: endPoint as! EndPointEntity)
			}
			.sink(receiveCompletion: { _ in
			}, receiveValue: {})
			.store(in: &cancellables)

		endPointListView.expandItem(nil, expandChildren: true)

		deleteEndPointSubject
			.removeDuplicates()
			.map { [weak self] endPoint -> EndPoint in
				guard let self = self else { return endPoint }
				let entity = try! self.context.fetchOne(EndPointEntity.self, "id = %@", endPoint._id)!
				self.context.delete(entity)
				try! self.context.save()
//				self.reloadTableSubject.send()
				return endPoint
			}
			.flatMap { endPoint in
				BackendAgent.default.deleteEndPoint(by: endPoint.url)
			}
			.sink(receiveCompletion: { _ in }, receiveValue: {})
			.store(in: &cancellables)
	}

	@IBAction func onDelete(_ sender: NSMenuItem) {
		let endPoint = endPointListView.item(atRow: endPointListView.clickedRow) as! EndPoint

		deleteEndPointSubject.send(endPoint)
	}
}
