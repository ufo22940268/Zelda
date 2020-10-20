//
//  EndPointDetailViewController+Table.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa

extension EndPointDetailViewController: NSTableViewDelegate, NSTableViewDataSource {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let identifier = tableColumn!.identifier.rawValue
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(identifier), owner: self) as? NSTableCellView
		let scanLog = validScanLogs[row]
		switch identifier {
		case "time":
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.timeStyle = .short
			view?.textField?.stringValue = formatter.string(from: scanLog.time)
		case "value":
			if indicator == .duration {
				view?.textField?.stringValue = scanLog.duration.formatDuration
			}
		case "action":
			break
		default:
			break
		}
		return view
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		guard detailTableView.selectedRow >= 0 else { return }
		let selectedView = detailTableView.view(atColumn: 2, row: detailTableView.selectedRow, makeIfNecessary: true)!
		let vc: NSViewController = storyboard!.instantiateController(identifier: "popup")
		present(vc, asPopoverRelativeTo: selectedView.bounds, of: selectedView, preferredEdge: .maxX, behavior: .transient)
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		validScanLogs.count
	}
}
