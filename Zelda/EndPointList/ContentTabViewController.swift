//
//  EndPointListTabViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/21.
//

import Cocoa

protocol IMainContent {
	var endPoints: [EndPoint] { get set }
	var selectedTabViewItemIndex: Int { get set }
}

class ContentTabViewController: NSTabViewController, IMainContent {
	var mainSplits: [ContentSplit] {
		tabViewItems.map {
			$0.viewController as! ContentSplit
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
			var split = (tabViewItems[item.rawValue].viewController as! ContentSplit)
			split.type = item
		}
	}

	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		(tabViewItem?.viewController as! ContentSplit).onSwitch()
	}
}
