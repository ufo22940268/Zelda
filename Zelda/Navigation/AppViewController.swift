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

	var sideBarVC: SidebarViewController!
	var listTabVC: IMainContent!
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
			.throttle(for: 10, scheduler: DispatchQueue.global(), latest: true)
			.flatMap { () in
				BackendAgent.default.listEndPoints()
			}
			.replaceError(with: [])
			.receive(on: DispatchQueue.main, options: nil)
			.assign(to: &$endPoints)

		syncSubject.send()

		$endPoints
			.receive(on: DispatchQueue.main)
			.sink { [weak self] endPoints in
				self?.listTabVC.endPoints = endPoints
				self?.sideBarVC.endPoints = endPoints
			}
			.store(in: &cancellables)

		NotificationCenter.default.publisher(for: .startRefresh)
			.sink { [weak self] _ in
				self?.syncSubject.send()
			}
			.store(in: &cancellables)

		let timer = Timer.TimerPublisher(interval: 20, runLoop: .main, mode: .common)

		timer
			.receive(on: DispatchQueue.global(qos: .background))
			.sink { [weak self] _ in
				self?.syncSubject.send()
			}
			.store(in: &cancellables)

		timer.connect()
			.store(in: &cancellables)
	}

	// MARK: Private

	private func setupViewControllers() {
		sideBarVC = splitViewItems[0].viewController as? SidebarViewController
		listTabVC = splitViewItems[1].viewController as? IMainContent

		sideBarVC.listTabVC = listTabVC
	}
}
