//
//  EndPointListViewController+OutlineTable.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Foundation

extension EndPointListViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
	var groupData: [(String, [EndPoint])] {
		Dictionary(grouping: endPoints) { $0.url.hostname }
			.map { ($0.key, $0.value.sorted { $0.url.endPointPath < $1.url.endPointPath }) }
			.sorted { $0.0 < $1.0 }
	}

	func loadData() -> [EndPoint] {
		// TODO: Load data by category.

		try! context.fetchMany(EndPointEntity.self)
			.map { $0.toItem() }
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return groupData[index].0
		} else {
			return (groupData.first { $0.0 == (item as! String) })!.1[index]
		}
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if item is String {
			return true
		} else {
			return false
		}
	}

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return groupData.count
		} else {
			if item is String {
				return (groupData.first { $0.0 == (item as! String) })!.1.count
			} else {
				return 0
			}
		}
	}

	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if item is String {
			return true
		} else {
			return false
		}
	}

	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return !self.outlineView(outlineView, isGroupItem: item)
	}

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("header"), owner: self) as! NSTableCellView
		if let item = item as? String {
			view.textField?.stringValue = item
		}

		if let item = item as? EndPoint {
			view.textField?.stringValue = item.url.endPointPath
		}

		return view
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		if let item = outlineView.item(atRow: outlineView.selectedRow) as? EndPoint {
			detailVC.load(endPoint: item._id)
		}
		print("selected", outlineView.selectedRow)
	}
}
