//
//  SideBarContentViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

class EndPointListViewController: NSViewController {
	@IBOutlet var outlineView: NSOutlineView!
	var cancellables = Set<AnyCancellable>()
	var context = NSManagedObjectContext.main
	var endPoints: [EndPoint] = []
	var syncSubject = PassthroughSubject<Void, Never>()
	var detailVC: EndPointDetailViewController!

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

		outlineView.expandItem(nil, expandChildren: true)

		syncSubject
			.flatMap { [weak self] () in
				BackendAgent.default.syncFromServer(context: self?.context ?? .main)
			}
			.catch { _ in
				Empty()
			}
			.map { [weak self] _ -> [EndPoint] in
				self?.loadData() ?? []
			}
			.sink(receiveValue: { [weak self] v in
				guard let self = self else { return }
				self.endPoints = v
				self.outlineView.reloadData()
				self.outlineView.expandItem(nil, expandChildren: true)
				self.outlineView.selectRowIndexes(IndexSet([1]), byExtendingSelection: true)
			})
			.store(in: &cancellables)

		syncSubject.send()
	}
}
