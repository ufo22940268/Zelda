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
}

typealias QueryParam = Param

protocol ParamTable {
	var params: [Param] { get set }
}

class RequestParamsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet var listView: NSTableView!

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
			listView.reloadData()
			NotificationCenter.default.post(.init(name: .endPointEditTableChanged))
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		params = [Param(key: "a", value: "b"), Param(key: "c", value: "d")]
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
			if listView.selectedRow > 0 {
				params.remove(at: listView.selectedRow)
				listView.reloadData()
			}
		} else if sender.selectedSegment == 0 {
			// Add
			listView.beginUpdates()
			listView.insertRows(at: IndexSet(integer: params.count), withAnimation: .effectFade)
			listView.endUpdates()
			listView.editColumn(0, row: params.count, with: nil, select: true)
		}
	}

	@IBAction func onUpdateValue(_ sender: NSTextField) {
		guard let row = selectedRow else { return }
		params[row].value = sender.stringValue
	}

	@IBAction func onUpdateKey(_ sender: NSTextField) {
		guard let row = selectedRow else { return }
		params[row].key = sender.stringValue
	}
}

extension RequestParamsViewController: ParamTable {}
