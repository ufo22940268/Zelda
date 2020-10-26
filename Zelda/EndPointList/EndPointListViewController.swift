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
	var detailVC: EndPointLoadable! { set get }
	func onSwitch()
	var type: SideBarItem! { get set }
}

class EndPointListViewController: NSViewController, IEndPointList {
	// MARK: Internal

	@IBOutlet var endPointListView: NSOutlineView!
	var cancellables = Set<AnyCancellable>()
	var context = NSManagedObjectContext.main
	var syncSubject = PassthroughSubject<Void, Never>()
	var deleteEndPointSubject = PassthroughSubject<EndPoint, Never>()
	var detailVC: EndPointLoadable!
	var type: SideBarItem! = .all
	var emptyView: EmptyView!

	var endPoints: [EndPoint] = [] {
		didSet {
			self.refreshView()
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

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if let emptyView = segue.destinationController as? EmptyView {
			self.emptyView = emptyView
		}
	}

	@IBAction func onDelete(_ sender: NSMenuItem) {
		let endPoint = endPointListView.item(atRow: endPointListView.clickedRow) as! EndPoint

		deleteEndPointSubject.send(endPoint)
	}

	func onSwitch() {
		refreshView()
	}

	// MARK: Private

	private func refreshView() {
		endPointListView.reloadData()
		endPointListView.expandItem(nil, expandChildren: true)

		if endPointListView.numberOfRows == 0 {
			emptyView.label = type.emptyText
		} else {
			emptyView.label = nil
		}
	}

	private func setupObservers() {
		NotificationCenter.default.publisher(for: .deleteEndPoint).sink { [weak self] notif in
			let endPoint = notif.object as! EndPoint
			self?.endPointListView.reloadData()
			self?.endPoints.removeAll { $0 == endPoint }
		}
		.store(in: &cancellables)
	}
}

extension EndPointListViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
	var groupData: [(String, [EndPoint])] {
		Dictionary(grouping: endPoints) { $0.url.hostname }
			.map { ($0.key, $0.value.sorted { $0.url.endPointPath < $1.url.endPointPath }) }
			.sorted { $0.0 < $1.0 }
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return groupData[index].0
		} else {
			return (groupData.first { $0.0 == (item as! String) })!.1[index]
		}
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if item is String {
			return true
		} else {
			return false
		}
	}

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return groupData.count
		} else {
			if item is String {
				return (groupData.first { $0.0 == (item as! String) })!.1.count
			} else {
				return 0
			}
		}
	}

	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if item is String {
			return true
		} else {
			return false
		}
	}

	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return !self.outlineView(outlineView, isGroupItem: item)
	}

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("header"), owner: self) as! NSTableCellView
		if let item = item as? String {
			view.textField?.stringValue = item
		}

		if let item = item as? EndPoint {
			view.textField?.stringValue = item.url.endPointPath
		}

		return view
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		if let item = endPointListView.item(atRow: endPointListView.selectedRow) as? EndPoint {
			detailVC.load(endPoint: item._id, url: item.url)
		}
	}
}
