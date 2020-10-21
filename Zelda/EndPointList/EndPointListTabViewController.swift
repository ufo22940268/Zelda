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
		setupLists()
	}
	
	func setupLists() {
		for item in SideBarItem.allCases {
			endPointListVCS[item.rawValue].type = item
		}
	}

	func load() {
		tabViewItems.forEach { ($0.viewController as! EndPointListViewController).reloadTable() }
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		print(segue)
	}
}
