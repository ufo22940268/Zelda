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

	@Published var url: String = ""
	var validateResultSubject = CurrentValueSubject<ValidateURLResult, Never>(.initial)
	@IBOutlet var prompt: NSTextField!
	var apiData = [String: String]()
	@IBOutlet var tableView: NSTableView!
	var watchPathsSubject = CurrentValueSubject<Set<String>, Never>(Set<String>())
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var confirmButton: NSButton!

	var type = EndPointEditType.edit

	var context: NSManagedObjectContext {
		type.context
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		confirmButton.setPrimary()
		$url
			.map { [weak self] url -> String in
				guard let self = self else { return "" }
				if !self.validateResultSubject.value.isProcessing, self.validateResultSubject.value != .initial {
					self.validateResultSubject.send(.pending)
				}

				return url
			}
			.filter { !$0.isEmpty }
			.debounce(for: 1, scheduler: DispatchQueue.main)
			.flatMap { [weak self] url -> AnyPublisher<ValidateURLResult, Never> in
				guard let self = self else { return Just(ValidateURLResult.duplicatedUrl).eraseToAnyPublisher() }
				if self.isDuplicated(url: url) {
					return Just(ValidateURLResult.duplicatedUrl).eraseToAnyPublisher()
				} else {
					return ApiHelper.validate(url: url).eraseToAnyPublisher()
				}
			}
			.receive(on: DispatchQueue.main)
			.subscribe(validateResultSubject)
			.store(in: &cancellables)

		validateResultSubject.sink { [weak self] result in
			guard let self = self else { return }

			self.prompt.stringValue = result.label
			if case .ok(let json) = result {
				self.load(apiData: json.convertToPathMap())
				self.confirmButton.isEnabled = true
			} else {
				self.load(apiData: [String: String]())
				self.confirmButton.isEnabled = false
			}
		}.store(in: &cancellables)

		validateResultSubject.combineLatest(watchPathsSubject)
			.sink { [weak self] ar in
				let (result, watch) = ar
				if case .ok = result, watch.count > 0 {
					self?.confirmButton.isEnabled = true
				} else {
					self?.confirmButton.isEnabled = false
				}
			}
			.store(in: &cancellables)
	}

	func controlTextDidChange(_ obj: Notification) {
		guard let field = obj.object as? NSTextField else { return }
		url = field.stringValue
	}

	@IBAction func onConfirm(_ sender: Any) {
		let endPointId = saveEndPoint()
		NotificationCenter.default.post(name: .syncEndPoint, object: endPointId.uriRepresentation())
		presentingViewController?.dismiss(self)
	}

	@IBAction func onCancel(_ sender: Any) {
		presentingViewController?.dismiss(self)
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
