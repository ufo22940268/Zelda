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

class EndPointDetailTabViewController: NSTabViewController {
	var loadables: [EndPointLoadable] {
		tabViewItems.map {
			$0.viewController as! EndPointLoadable
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
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
