//
//  SideBarViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa

enum SideBarItem: Int, CaseIterable {
	case all
	case issue
	case duration

	// MARK: Internal

	var label: String {
		switch self {
		case .all:
			return "全部"
		case .issue:
			return "异常"
		case .duration:
			return "超时"
		}
	}

	var icon: NSImage? {
		switch self {
		case .all:
			return NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
		case .issue:
			return NSImage(systemSymbolName: "ladybug", accessibilityDescription: nil)
		case .duration:
			return NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
		}
	}

	func count(of endPoints: [EndPoint]) -> Int? {
		switch self {
		case .all:
			return nil
		case .issue:
			return endPoints.reduce(0) { $0 + ($1.hasIssue ? 1 : 0) }
		case .duration:
			return endPoints.reduce(0) { $0 + ($1.hasTimeout ? 1 : 0) }
		}
	}
}

protocol IMainSideBar {
	var listTabVC: IMainContent! { get set }
	var endPoints: [EndPoint] { get set }
}

class SideBarItemView: NSTableCellView {
	@IBOutlet var countView: NSButton!

	var count: Int? {
		didSet {
			if let count = count {
				countView.isHidden = false
				countView.title = String(count)
			} else {
				countView.isHidden = true
			}
		}
	}
}

class SideBarViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
	@IBOutlet var tableView: NSTableView!
	var listTabVC: IMainContent!
	var endPoints: [EndPoint] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return SideBarItem.allCases.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as! SideBarItemView
		let item = SideBarItem.allCases[row]
		view.textField?.stringValue = item.label
		view.imageView?.image = item.icon
		view.count = item.count(of: endPoints)
		return view
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		listTabVC.selectedTabViewItemIndex = tableView.selectedRow
	}
}
