//
//  ViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/12.
//

import Cocoa

class AppSideBarViewController: NSSplitViewController {
	
	var sideBarVC: SideBarViewController!
	var listVC: EndPointListViewController!
	var detailVC: EndPointDetailViewController!

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViewControllers()
	}
	
	private func setupViewControllers() {
		sideBarVC = splitViewItems[0].viewController as? SideBarViewController
		listVC = splitViewItems[1].viewController as? EndPointListViewController
		detailVC = splitViewItems[2].viewController as? EndPointDetailViewController
		
		listVC.detailVC = detailVC
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

