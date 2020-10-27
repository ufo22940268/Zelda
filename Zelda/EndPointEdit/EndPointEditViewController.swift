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
	var saveSubject = PassthroughSubject<EndPointReq, Never>()
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var confirmButton: NSButton!
	var type = EndPointEditType.edit

	var endPointToUpsert: EndPointReq? {
		EndPointReq(url: url, watchFields: apiDataArray.filter { watchPathsSubject.value.contains($0.0) }.map { path, value in EndPointReq.WatchField(path: path, value: value) })
	}

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

		saveSubject
			.debounce(for: 1, scheduler: DispatchQueue.main)
			.handleEvents(receiveOutput: { [weak self] _ in
				DispatchQueue.main.async {
					self?.confirmButton.isEnabled = false
				}
			})
			.flatMap { endPoint in
				BackendAgent.default.upsert(endPoint: endPoint)
			}
			.receive(on: DispatchQueue.main, options: nil)
			.handleEvents(receiveOutput: { [weak self] _ in
				self?.confirmButton.isEnabled = true
			})
			.sink(receiveCompletion: { _ in }, receiveValue: { [weak self]() in
				self?.view.window?.close()
			})
			.store(in: &cancellables)
	}

	func controlTextDidChange(_ obj: Notification) {
		guard let field = obj.object as? NSTextField else { return }
		url = field.stringValue
	}

	@IBAction func onConfirm(_ sender: Any) {
		if let endPointToUpsert = endPointToUpsert {
			saveSubject.send(endPointToUpsert)
		}
	}

	func saveEndPoint() -> NSManagedObjectID {
		let ep = EndPointEntity(context: context)
		ep.url = url

		for api in apiDataArray.filter({ watchPathsSubject.value.contains($0.0) }) {
			let (path, value) = api
			let apiEntity = ApiEntity(context: context)
			apiEntity.endPoint = ep
			apiEntity.paths = path
			apiEntity.value = value
		}

		try! context.save()
		try! context.parent!.save()

		return ep.objectID
	}

	@IBAction func onCancel(_ sender: Any) {
//		dismiss(self)
		self.view.window?.close()
//		presentingViewController?.dismiss(self)
	}

	func isDuplicated(url: String) -> Bool {
		try! context.fetchOne(EndPointEntity.self, "url = %@", url) != nil
	}

	// MARK: Private

	private func load(apiData: [String: String]) {
		self.apiData = apiData
//		tableView.reloadData()
	}
}

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
