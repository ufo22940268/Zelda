//
//  EndPointEditViewController+Table.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import AppKit
import Foundation

extension EndPointEditViewController: NSTableViewDelegate, NSTableViewDataSource {
	var apiDataArray: [(String, String)] {
		apiData.enumerated()
			.sorted(by: { $0.element.key < $1.element.key })
			.map { $0.element }
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		apiData.count
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		let (path, value) = apiDataArray[row]
		if tableColumn?.identifier.rawValue == "key" {
			return path
		} else if tableColumn?.identifier.rawValue == "value" {
			return value
		} else if tableColumn?.identifier.rawValue == "check" {
			return watchPathsSubject.value.contains(path)
		}
		
		return nil
	}

	func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
		guard let identifier = tableColumn?.identifier else { return }
		if identifier.rawValue == "check" {
			let checked = object as! Bool
			if checked {
				watchPathsSubject.value.insert(apiDataArray[row].0)
			} else {
				watchPathsSubject.value.remove(apiDataArray[row].0)
			}
		}
	}
}
