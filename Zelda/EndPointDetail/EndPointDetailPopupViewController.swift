//
//  EndPointDetailPopupViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa

let testRecordItem = RecordItem(duration: 100, statusCode: 8, time: Date(), requestHeader: "", responseHeader: "server:nginx/1.10.2\ndate:Tue, 15 Sep 2020 11:59:29 GMT\ncontent-type:text/plain\ncontent-length:110\nlast-modified:Sun, 16 Aug 2020 23:47:44 GMT\nconnection:close\netag:\"5f39c5a0-6e\"\naccept-ranges:bytes", responseBody: "", fields: [])

class EndPointDetailPopupViewController: NSViewController {
	// MARK: Internal

	var recordItem: RecordItem = testRecordItem

	@IBOutlet var headerView: NSGridView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		loadRecordItem()
	}

	func loadRecordItem() {
		for (k, v) in recordItem.responseHeader.dict {
			appendRow(k, v)
		}
	}

	// MARK: Private

	private func appendRow(_ k: String, _ v: String) {
		headerView.addRow(with: [NSTextField(labelWithString: k.capitalized), NSTextField(labelWithString: v)])
	}
}
