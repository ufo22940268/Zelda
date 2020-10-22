//
//  MainSplitViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/21.
//

import Cocoa

protocol ContentSplit {
	var type: SideBarItem! { get set }
	var endPoints: [EndPoint] { get set }
	func onSwitch()
}

class ContentSplitViewController: NSSplitViewController, ContentSplit {
	var type: SideBarItem!

	lazy var listVC: IEndPointList = {
		(splitViewItems[0].viewController as! IEndPointList)
	}()
	
	lazy var detailVC: IEndPointDetail = {
		(splitViewItems[1].viewController as! IEndPointDetail)
	}()


	var endPoints: [EndPoint] = [] {
		didSet {
			switch type {
			case .all:
				listVC.endPoints = self.endPoints
			case .issue:
				listVC.endPoints = endPoints.filter { $0.hasIssue }
			case .duration:
				listVC.endPoints = endPoints.filter { $0.hasTimeout }
			case .none:
				break
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		listVC.detailVC = detailVC
	}
	

	func onSwitch() {
		listVC.onSwitch()
	}
}
