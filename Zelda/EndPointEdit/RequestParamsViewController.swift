//
//  RequestParamsViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/28.
//

import Cocoa

struct Param {
	var key: String
	var value: String

	var isEmpty: Bool {
		key.isEmpty || value.isEmpty
	}
}

typealias QueryParam = Param

protocol ParamTable {
	var params: [Param] { get set }
	func reload()

	func setEnabled(_ enabled: Bool)
}

class RequestParamsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet var listView: NSTableView!
	@IBOutlet var stepperView: NSSegmentedControl!

	var selectedParam: Param? {
		if (0 ..< params.count).contains(listView.selectedRow) {
			return params[listView.selectedRow]
		} else {
			return nil
		}
	}

	var selectedRow: Int? {
		if (0 ..< params.count).contains(listView.selectedRow) {
			return listView.selectedRow
		} else {
			return nil
		}
	}

	var params = [Param]() {
		didSet {
			NotificationCenter.default.post(.init(name: .endPointEditTableChanged))
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setEnabled(false)
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let id = tableColumn!.identifier.rawValue
		let view = tableView.makeView(withIdentifier: .init(id), owner: self) as! NSTableCellView
		if row < params.count {
			let query = params[row]
			if id == "key" {
				view.textField?.stringValue = query.key
			} else {
				view.textField?.stringValue = query.value
			}
		} else {
			// Add new row
			view.textField?.stringValue = ""
		}
		return view
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return params.count
	}

	@IBAction func onUpdateQueryParams(_ sender: NSSegmentedCell) {
		if sender.selectedSegment == 1 {
			// Delete
			if let selectedRow = selectedRow {
				listView.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
			}
		} else if sender.selectedSegment == 0 {
			// MARK: Add

			if !hasEmptyTail() {
				listView.beginUpdates()
				listView.insertRows(at: IndexSet(integer: params.count), withAnimation: .effectFade)
				listView.endUpdates()
			}

			listView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
			listView.editColumn(0, row: params.count - 1, with: nil, select: true)
		}
	}

	func hasEmptyTail() -> Bool {
		params.last != nil && params.last!.key.isEmpty
	}

	func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
		params.append(Param(key: "", value: ""))
	}
	
	func tableView(_ tableView: NSTableView, didRemove rowView: NSTableRowView, forRow row: Int) {
		guard row != -1 else { return }
		params.remove(at: row)
	}

	@IBAction func onUpdateValue(_ sender: NSTextField) {
		guard let row = selectedRow else { return }
		params[row].value = sender.stringValue
	}

	@IBAction func onUpdateKey(_ sender: NSTextField) {
		guard let row = selectedRow else { return }
		params[row].key = sender.stringValue
	}

	func reload() {
		listView.reloadData()
	}
}

extension RequestParamsViewController: ParamTable {
	func setEnabled(_ enabled: Bool) {
		listView.isEnabled = enabled
		stepperView.isEnabled = enabled
	}
}
