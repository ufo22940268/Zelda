//
//  EndPointDetailPopupViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa
import Combine

let testRecordItem = RecordItem(duration: 100, statusCode: 8, time: Date(), requestHeader: "", responseHeader: "server:nginx/1.10.2\ndate:Tue, 15 Sep 2020 11:59:29 GMT\ncontent-type:text/plain\ncontent-length:110\nlast-modified:Sun, 16 Aug 2020 23:47:44 GMT\nconnection:close\netag:\"5f39c5a0-6e\"\naccept-ranges:bytes", responseBody: "{\"a\": 1, \"b\": {\"c\": 2}}", fields: [])

class EndPointDetailPopupViewController: NSViewController {
	// MARK: Internal

	@Published var recordItem: RecordItem?
	var scanLogId: String!
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var headerView: NSGridView!
	@IBOutlet var bodyView: NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		BackendAgent.default.getRecordItem(scanLogId: scanLogId)
			.map { v -> RecordItem? in v }
			.replaceError(with: nil)
			.assign(to: &$recordItem)
		
		$recordItem
			.filter { $0 != nil }
			.sink { [weak self] (item) in
				self?.loadRecordItem(item!)
			}
			.store(in: &cancellables)
	}

	func loadRecordItem(_ recordItem: RecordItem) {
		(0 ..< headerView.numberOfRows).forEach { headerView.removeRow(at: $0) }
		for (k, v) in recordItem.responseHeader.dict {
			appendRow(k, v)
		}
		bodyView.stringValue = recordItem.responseBody
	}

	// MARK: Private

	private func appendRow(_ k: String, _ v: String) {
		headerView.addRow(with: [NSTextField(labelWithString: k.capitalized), NSTextField(labelWithString: v.jsonPrettify ?? "")])
	}
}
