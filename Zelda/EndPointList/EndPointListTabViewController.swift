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

	var endPoints: [EndPoint] = [] {
		didSet {
			endPointListVCS.enumerated().forEach { i, vc in
				let type = SideBarItem(rawValue: i)!
				var endPoints = self.endPoints
				switch type {
				case .all:
					break
				case .bug:
					endPoints = endPoints.filter { $0.hasIssue }
				case .timeout:
					endPoints = endPoints.filter { $0.requestTimeout }
				}
				vc.endPoints = endPoints
			}
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

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		print(segue)
	}
}
