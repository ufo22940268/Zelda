//
//  ViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/12.
//

import Cocoa

class AppSideBarViewController: NSSplitViewController {
	// MARK: Internal

	var sideBarVC: SideBarViewController!
	var listVC: EndPointListViewController!
	var detailVC: EndPointDetailTabViewController!

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViewControllers()
	}

	// MARK: Private

	private func setupViewControllers() {
		sideBarVC = splitViewItems[0].viewController as? SideBarViewController
		listVC = splitViewItems[1].viewController as? EndPointListViewController
		detailVC = (splitViewItems[2].viewController as? EndPointDetailContainerViewController)?.tabVC as? EndPointDetailTabViewController

		listVC.detailVC = detailVC
	}
	
	func onSelectSpan(_ span: ScanLogSpan) {
		listVC.detailVC.onSelectSpan(span)
	}
}
