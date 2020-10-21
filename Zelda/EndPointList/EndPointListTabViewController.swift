//
//  EndPointListTabViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/21.
//

import Cocoa

class EndPointListTabViewController: NSTabViewController {
	var endPointListVCS: [EndPointListViewController] {
		tabViewItems.map { $0.viewController as! EndPointListViewController }
	}

	var detailVC: EndPointDetailTabViewController! {
		didSet {
			endPointListVCS.forEach { $0.detailVC = self.detailVC }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}

	func load() {
		tabViewItems.forEach { ($0.viewController as! EndPointListViewController).reloadTable() }
	}
}
