//
//  SideBarContentViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

protocol IEndPointList {
	var endPoints: [EndPoint] { set get }
	var detailVC: IEndPointDetail! { set get }
	func onSwitch()
}

class EndPointListViewController: NSViewController, IEndPointList {
	// MARK: Internal

	@IBOutlet var endPointListView: NSOutlineView!
	var cancellables = Set<AnyCancellable>()
	var context = NSManagedObjectContext.main
	var syncSubject = PassthroughSubject<Void, Never>()
	var deleteEndPointSubject = PassthroughSubject<EndPoint, Never>()
	var detailVC: IEndPointDetail!
	var type: SideBarItem!

	var endPoints: [EndPoint] = [] {
		didSet {
			endPointListView.reloadData()
			self.endPointListView.expandItem(nil, expandChildren: true)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		deleteEndPointSubject
			.removeDuplicates()
			.map { (endPoint: EndPoint) -> EndPoint in
				NotificationCenter.default.post(name: .deleteEndPoint, object: endPoint)
				return endPoint
			}
			.flatMap { endPoint in
				BackendAgent.default.deleteEndPoint(by: endPoint.url)
			}
			.sink(receiveCompletion: { _ in }, receiveValue: {})
			.store(in: &cancellables)

		setupObservers()
	}

	func onDeleteEndPoint() {}

	@IBAction func onDelete(_ sender: NSMenuItem) {
		let endPoint = endPointListView.item(atRow: endPointListView.clickedRow) as! EndPoint

		deleteEndPointSubject.send(endPoint)
	}

	func onSwitch() {
		endPointListView.reloadData()
		endPointListView.expandItem(nil, expandChildren: true)
	}

	// MARK: Private

	private func setupObservers() {
		NotificationCenter.default.publisher(for: .deleteEndPoint).sink { [weak self] notif in
			let endPoint = notif.object as! EndPoint
			self?.endPointListView.reloadData()
			self?.endPoints.removeAll { $0 == endPoint }
		}
		.store(in: &cancellables)
	}
}
