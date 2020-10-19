//
//  EndPointDetailViewController+Table.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa

extension EndPointDetailViewController: NSTableViewDelegate, NSTableViewDataSource {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("time"), owner: self) as? NSTableCellView
		let scanLog = scanLogs[row]
		switch tableColumn!.identifier.rawValue {
		case "time":
			let formatter = DateFormatter()
			view?.textField?.stringValue = formatter.string(from: scanLog.time)
		case "value":
			if indicator == .duration {
				view?.textField?.stringValue = scanLog.duration.formatDuration
			}
		default:
			break
		}
		return view
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		scanLogs.count
	}
}
