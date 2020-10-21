//
//  ViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/12.
//

import Cocoa
import Combine

class AppViewController: NSSplitViewController {
	// MARK: Internal

	var sideBarVC: SideBarViewController!
	var listTabVC: EndPointListTabViewController!
	var detailVC: EndPointDetailTabViewController!

	var syncSubject = PassthroughSubject<Void, Never>()
	var context = NSManagedObjectContext.main
	var cancellables = Set<AnyCancellable>()

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViewControllers()

		syncSubject
			.flatMap { [weak self] () in
				BackendAgent.default.syncFromServer(context: self?.context ?? .main)
			}
			.sink(receiveCompletion: { _ in }) { [weak self] () in
				self?.listTabVC.load()
			}
			.store(in: &cancellables)

		syncSubject.send()
	}

	func onSelectSpan(_ span: ScanLogSpan) {
//		listVC.detailVC.onSelectSpan(span)
	}

	// MARK: Private

	private func setupViewControllers() {
		sideBarVC = splitViewItems[0].viewController as? SideBarViewController
		listTabVC = splitViewItems[1].viewController as? EndPointListTabViewController
		detailVC = (splitViewItems[2].viewController as? EndPointDetailContainerViewController)?.tabVC as? EndPointDetailTabViewController

		sideBarVC.listTabVC = listTabVC
		listTabVC.detailVC = detailVC
	}
}
