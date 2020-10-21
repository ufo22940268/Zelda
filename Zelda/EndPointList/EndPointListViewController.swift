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
	var endPoints: [EndPoint] = []
	var syncSubject = PassthroughSubject<Void, Never>()
	var reloadTableSubject = PassthroughSubject<Void, Never>()
	var deleteEndPointSubject = PassthroughSubject<EndPoint, Never>()
	var detailVC: EndPointDetailTabViewController!

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

		syncSubject
			.flatMap { [weak self] () in
				BackendAgent.default.syncFromServer(context: self?.context ?? .main)
			}
			.catch { _ in
				Empty()
			}
			.subscribe(reloadTableSubject)
			.store(in: &cancellables)

		syncSubject.send()
		reloadTableSubject
			.map { [weak self] _ -> [EndPoint] in
				self?.loadData() ?? []
			}
			.sink(receiveValue: { [weak self] v in
				guard let self = self else { return }
				self.endPoints = v
				self.endPointListView.reloadData()
				self.endPointListView.expandItem(nil, expandChildren: true)
//				self.endPointListView.selectRowIndexes(IndexSet([1]), byExtendingSelection: true)
			})
			.store(in: &cancellables)

		deleteEndPointSubject
			.removeDuplicates()
			.map { [weak self] endPoint -> EndPoint in
				guard let self = self else { return endPoint }
				let entity = try! self.context.fetchOne(EndPointEntity.self, "id = %@", endPoint._id)!
				self.context.delete(entity)
				try! self.context.save()
				self.reloadTableSubject.send()
				return endPoint
			}
			.flatMap { endPoint in
				BackendAgent.default.deleteEndPoint(by: endPoint.url)
			}
			.sink(receiveCompletion: { _ in }, receiveValue: {})
			.store(in: &cancellables)
	}

	func reloadTable() {
		reloadTableSubject.send()
	}

	@IBAction func onDelete(_ sender: NSMenuItem) {
		let endPoint = endPointListView.item(atRow: endPointListView.clickedRow) as! EndPoint

		deleteEndPointSubject.send(endPoint)
	}
}
