//
//  EndPointEditViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa
import Combine

class EndPointEditViewController: NSViewController, NSTextFieldDelegate {
	// MARK: Internal

	@IBOutlet var urlView: NSTextField!
	@Published var url: String = ""
	var validateResultSubject = CurrentValueSubject<ValidateURLResult, Never>(.initial)
	var apiData = [String: String]()
	@IBOutlet var tableView: NSTableView!
	var watchPathsSubject = CurrentValueSubject<Set<String>, Never>(Set<String>())
	var saveSubject = PassthroughSubject<EndPointReq, Never>()
	var cancellables = Set<AnyCancellable>()
	var queryTable: ParamTable!

	@IBOutlet var confirmButton: NSButton!
	var type = EndPointEditType.edit

	var context: NSManagedObjectContext {
		type.context
	}

	var queries: [QueryParam] {
		queryTable.params
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		confirmButton.setPrimary()
		$url
			.filter { $0.isValidURL() }
			.sink { [weak self] url in
				if let url = URLComponents(string: url) {
					self?.queryTable.params = url.queryItems?.params ?? []
					self?.queryTable.reload()
				}
			}
			.store(in: &cancellables)
		
		$url
			.map { $0.isValidURL() }
			.sink { [weak self] valid in
				if let table = self?.queryTable {
					table.setEnabled(valid)
				}
			}
			.store(in: &cancellables)
		
		setupObservers()
	}

	func controlTextDidChange(_ obj: Notification) {
		guard let field = obj.object as? NSTextField else { return }
		url = field.stringValue
	}

	func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {}

	@IBAction func onCancel(_ sender: Any) {
		view.window?.close()
	}

	func isDuplicated(url: String) -> Bool {
		try! context.fetchOne(EndPointEntity.self, "url = %@", url) != nil
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "queryParams" {
			queryTable = segue.destinationController as? ParamTable
		}
	}

	// MARK: Private

	private func setupObservers() {
		NotificationCenter.default.publisher(for: .endPointEditTableChanged)
			.sink { [weak self] _ in
				self?.syncQueryToURL()
			}
			.store(in: &cancellables)
	}

	private func syncQueryToURL() {
		guard !url.isEmpty else {
			return
		}

		if var url = URLComponents(string: self.url) {
			url.queryItems = queries.filter { !$0.isEmpty }.queryItems
			urlView.stringValue = url.string ?? ""
		}
	}

	private func load(apiData: [String: String]) {
		self.apiData = apiData
	}
}

extension EndPointEditViewController: NSTableViewDelegate, NSTableViewDataSource {
	enum Kind: CaseIterable {
		case query
		case headers

		// MARK: Internal

		var label: String {
			switch self {
			case .query:
				return "Query Params"
			case .headers:
				return "Headers"
			}
		}
	}

	enum Table: String {
		case queryParams
		case headers
	}
}
