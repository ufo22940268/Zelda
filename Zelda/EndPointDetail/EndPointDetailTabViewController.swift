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

protocol EndPointDetailLoadable: EndPointLoadable {
	func setIndicator(_ indicator: EndPointIndicator)
	var endPointId: String? { get set }
}

class EndPointDetailTabViewController: NSTabViewController, IEndPointDetail {
	var endPointId: String?

	var loadables: [EndPointDetailLoadable] {
		tabViewItems.map { item -> EndPointDetailLoadable? in
			if let loadable = (item.viewController as? EndPointDetailContainer)?.loadable {
				return loadable
			} else {
				return nil
			}
		}.filter { $0 != nil }.map { $0! }
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		if let endPointId = endPointId {
			loadables.forEach { $0.load(endPoint: endPointId)}
		}
	}	
}

extension EndPointDetailTabViewController: EndPointLoadable {
	func load(endPoint: String) {
		loadables.forEach { $0.load(endPoint: endPoint) }
		endPointId = endPoint
	}

	func onSelectSpan(_ span: ScanLogSpan) {
		loadables.forEach { $0.onSelectSpan(span) }
	}
}
