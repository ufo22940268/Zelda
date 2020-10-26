//
//  EndPointDetailPopupViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa
import Combine

let testRecordItem = RecordItem(duration: 100, statusCode: 8, time: Date(), requestHeader: "", responseHeader: "server:nginx/1.10.2\ndate:Tue, 15 Sep 2020 11:59:29 GMT\ncontent-type:text/plain\ncontent-length:110\nlast-modified:Sun, 16 Aug 2020 23:47:44 GMT\nconnection:close\netag:\"5f39c5a0-6e\"\naccept-ranges:bytes", responseBody: "{\"a\": 1, \"b\": {\"c\": 2}}", fields: [], timings: RecordItem.Timings(wait: 0, dns: 0, tcp: 0, request: 1, firstByte: 3, download: 3, total: 4))

protocol IRecordDetail {
	var scanLogId: String! { get set }
}

class RecordDetailViewController: NSViewController, IRecordDetail {
	enum Kind {
		case duration
		case issue
	}

	@Published var recordItem: RecordItem?
	@Published var scanLogId: String!
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var timingView: NSTextView!
	@IBOutlet var monitorTableView: NSTableView!
	@IBOutlet var responseHeaderView: NSTextView!
	@IBOutlet var bodyView: NSTextView!

	var kind: EndPointDetailKind = .issue

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		$scanLogId
			.filter { $0 != nil }
			.flatMap {
				BackendAgent.default.getRecordItem(scanLogId: $0!)
			}
			.map { v -> RecordItem? in v }
			.replaceError(with: nil)
			.sink { [weak self] recordItem in
				self?.recordItem = recordItem
				self?.monitorTableView.reloadData()
			}
			.store(in: &cancellables)

		$recordItem
			.filter { $0 != nil }
			.sink { [weak self] item in
				self?.loadRecordItem(item!)
			}
			.store(in: &cancellables)

		responseHeaderView.textContainerInset = .init(width: 8, height: 8)
		bodyView.textContainerInset = .init(width: 8, height: 8)
		timingView.textContainerInset = .init(width: 8, height: 8)
	}

	func loadRecordItem(_ recordItem: RecordItem) {
		responseHeaderView.string = recordItem.responseHeader.format
		bodyView.string = recordItem.responseBody.jsonPrettify ?? ""
		timingView.string = recordItem.timings.format
	}
}

// MARK： Monitor table
extension RecordDetailViewController: NSTableViewDelegate, NSTableViewDataSource {
	var monitorFields: [RecordItem.WatchField] {
		recordItem?.fields ?? []
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		monitorFields.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let identifier = tableColumn!.identifier.rawValue
		let view = tableView.makeView(withIdentifier: .init(identifier), owner: self) as! NSTableCellView

		let field = monitorFields[row]
		if identifier == "path" {
			view.textField?.stringValue = field.path
		} else if identifier == "expectValue" {
			view.textField?.stringValue = field.watchValue ?? ""
		} else if identifier == "value" {
			view.textField?.stringValue = field.value
		}

		return view
	}
}
