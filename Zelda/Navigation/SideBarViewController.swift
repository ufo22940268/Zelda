//
//  SideBarViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa

enum SideBarItem: Int, CaseIterable {
	case all
	case bug
	case timeout

	// MARK: Internal

	var label: String {
		switch self {
		case .all:
			return "全部"
		case .bug:
			return "异常"
		case .timeout:
			return "超时"
		}
	}

	var icon: NSImage? {
		switch self {
		case .all:
			return NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
		case .bug:
			return NSImage(systemSymbolName: "ladybug", accessibilityDescription: nil)
		case .timeout:
			return NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
		}
	}
}

protocol IMainSideBar {
	var listTabVC: IMainContent! { get set }
}

class SideBarViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
	@IBOutlet var tableView: NSTableView!
	var listTabVC: IMainContent!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return SideBarItem.allCases.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as! NSTableCellView
		let item = SideBarItem.allCases[row]
		view.textField?.stringValue = item.label
		view.imageView?.image = item.icon
		return view
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		listTabVC.selectedTabViewItemIndex = tableView.selectedRow
	}
}
