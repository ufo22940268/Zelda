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
	var listTabVC: ContentTabViewController!
	var detailVC: EndPointDetailTabViewController!

	var syncSubject = PassthroughSubject<Void, Never>()
	var context = NSManagedObjectContext.main
	var cancellables = Set<AnyCancellable>()
	@Published var endPoints: [EndPoint] = []

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViewControllers()

		syncSubject
			.flatMap { () in
				BackendAgent.default.listEndPoints()
			}
			.replaceError(with: [])
			.assign(to: &$endPoints)

		syncSubject.send()

		$endPoints
			.receive(on: DispatchQueue.main)
			.sink { [weak self] endPoints in
				self?.listTabVC.endPoints = endPoints
			}
			.store(in: &cancellables)
	}

	func onSelectSpan(_ span: ScanLogSpan) {
//		listVC.detailVC.onSelectSpan(span)
	}

	// MARK: Private

	private func setupViewControllers() {
		sideBarVC = splitViewItems[0].viewController as? SideBarViewController
		listTabVC = splitViewItems[1].viewController as? ContentTabViewController

		sideBarVC.listTabVC = listTabVC
	}
}
