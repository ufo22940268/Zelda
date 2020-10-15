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

	var validateCancellable: AnyCancellable?
	var validateResultCancellable: AnyCancellable?
	@Published var url: String = ""
	var validateResultSubject = CurrentValueSubject<ValidateURLResult, Never>(.initial)
	@IBOutlet var prompt: NSTextField!
	var apiData = [String: String]()
	@IBOutlet var tableView: NSTableView!
	var watchPaths = Set<String>()

	var type = EndPointEditType.edit

	var context: NSManagedObjectContext {
		type.context
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		validateCancellable = $url
			.map { url -> String in
				if !self.validateResultSubject.value.isProcessing {
					self.validateResultSubject.send(.pending)
				}

				if url.isEmpty {
					self.validateResultSubject.send(.initial)
				}

				return url
			}
			.debounce(for: 1, scheduler: DispatchQueue.main)
			.flatMap { url -> AnyPublisher<ValidateURLResult, Never> in
				if self.isDuplicated(url: url) {
					return Just(ValidateURLResult.duplicatedUrl).eraseToAnyPublisher()
				} else {
					return ApiHelper.validate(url: url).eraseToAnyPublisher()
				}
			}
			.receive(on: DispatchQueue.main)
			.print()
			.subscribe(validateResultSubject)

		validateResultCancellable = validateResultSubject.sink { result in
			self.prompt.stringValue = result.label
			if case .ok(let json) = result {
				self.load(apiData: json.convertToPathMap())
			} else {
				self.load(apiData: [String: String]())
			}
		}
	}

	func controlTextDidChange(_ obj: Notification) {
		guard let field = obj.object as? NSTextField else { return }
		url = field.stringValue
	}

	@IBAction func onConfirm(_ sender: Any) {
		let endPointId = saveEndPoint()
		NotificationCenter.default.post(name: .syncEndPoint, object: endPointId)
		presentingViewController?.dismiss(self)
	}
	
	override func viewDidDisappear() {
		validateCancellable?.cancel()
		validateResultCancellable?.cancel()
	}

	func isDuplicated(url: String) -> Bool {
		try! context.fetchOne(EndPointEntity.self, "url = %@", url) != nil
	}

	// MARK: Private

	private func load(apiData: [String: String]) {
		self.apiData = apiData
		tableView.reloadData()
	}
}
