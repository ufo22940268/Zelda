//
//  EndPointListTabViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/21.
//

import Cocoa

class ContentTabViewController: NSTabViewController {
	var mainSplits: [MainSplit] {
		tabViewItems.map {
			$0.viewController as! MainSplit
		}
	}

	var endPoints: [EndPoint] = [] {
		didSet {
			mainSplits.forEach { split in
				var ns = split
				ns.endPoints = self.endPoints
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLists()
	}

	func setupLists() {
		for item in SideBarItem.allCases {
			var split = (tabViewItems[item.rawValue].viewController as! MainSplit)
			split.type = item
		}
	}
}
