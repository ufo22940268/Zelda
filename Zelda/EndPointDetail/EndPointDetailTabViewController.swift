//
//  EndPointDetailTabViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa

protocol EndPointLoadable {
	func load(endPoint: String)
	func onSelectSpan(_ span: ScanLogSpan)
}

protocol EndPointDetailLoadabble: EndPointLoadable {
	func setIndicator(_ indicator: EndPointIndicator)
}

class EndPointDetailTabViewController: NSTabViewController {
	var loadables: [EndPointDetailLoadabble] {
		tabViewItems.map {
			$0.viewController as! EndPointDetailLoadabble
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		loadables.forEach { $0.setIndicator(EndPointIndicator(identifier: tabViewItem?.identifier as! String)) }
	}
}

extension EndPointDetailTabViewController: EndPointLoadable {
	func load(endPoint: String) {
		loadables.forEach { $0.load(endPoint: endPoint) }
	}

	func onSelectSpan(_ span: ScanLogSpan) {
		loadables.forEach { $0.onSelectSpan(span) }
	}
}
