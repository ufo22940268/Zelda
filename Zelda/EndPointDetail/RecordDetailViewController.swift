//
//  EndPointDetailPopupViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa
import Combine

let testRecordItem = RecordItem(duration: 100, statusCode: 8, time: Date(), requestHeader: "", responseHeader: "server:nginx/1.10.2\ndate:Tue, 15 Sep 2020 11:59:29 GMT\ncontent-type:text/plain\ncontent-length:110\nlast-modified:Sun, 16 Aug 2020 23:47:44 GMT\nconnection:close\netag:\"5f39c5a0-6e\"\naccept-ranges:bytes", responseBody: "{\"a\": 1, \"b\": {\"c\": 2}}", fields: [])

protocol IRecordDetail {
	var scanLogId: String! { get set }
}

class RecordDetailViewController: NSViewController, IRecordDetail {
	// MARK: Internal

	enum Kind {
		case duration
		case issue
	}

	@Published var recordItem: RecordItem?
	@Published var scanLogId: String!
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var headerView: NSGridView!
//	@IBOutlet var bodyView: NSTextField!
	@IBOutlet var watchView: NSGridView!
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
			.assign(to: &$recordItem)

		$recordItem
			.filter { $0 != nil }
			.sink { [weak self] item in
				self?.loadRecordItem(item!)
			}
			.store(in: &cancellables)
		setupWatchView()
	}

	func loadRecordItem(_ recordItem: RecordItem) {
		headerView.removeRows()
		for (k, v) in recordItem.responseHeader.dict {
			appendRow(k, v)
		}
		bodyView.string = recordItem.responseBody
	}

	// MARK: Fileprivate

	fileprivate func setupWatchView() {
		switch kind {
		case .duration:
			watchView.isHidden = true
		case .issue:
			fillWatchHeader()
		}
	}

	// MARK: Private

	private func fillWatchHeader() {
		watchView.removeRows()
		recordItem?.fields.forEach { field in
			watchView.addRow(with: [makeTextCell(str: field.path), makeTextCell(str: field.watchValue ?? "")])
		}
	}

	private func makeTextCell(str: String) -> NSTextField {
		let tf = NSTextField(labelWithString: str)
		tf.font = .toolTipsFont(ofSize: 12)
		return tf
	}

	private func appendRow(_ k: String, _ v: String) {
		headerView.addRow(with: [makeTextCell(str: k.capitalized), makeTextCell(str: v.jsonPrettify ?? "")])
	}
}
