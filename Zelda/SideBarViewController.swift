//
//  SideBarViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa

enum SideBarItem: CaseIterable {
	case dashboard
	case history
	case more

	// MARK: Internal

	var label: String {
		switch self {
		case .dashboard:
			return "监控"
		case .history:
			return "记录"
		case .more:
			return "更多"
		}
	}
	
	var icon: NSImage? {
		switch self {
		case .dashboard:
			return NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: nil)
		case .history:
			return NSImage(systemSymbolName: "clock.fill", accessibilityDescription: nil)
		case .more:
			return NSImage(systemSymbolName: "lineweight", accessibilityDescription: nil)
		}
	}
}

class SideBarViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
	@IBOutlet var tableView: NSTableView!

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
}
