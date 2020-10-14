//
//  EndPointEditViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa
import Combine

class EndPointEditViewController: NSViewController, NSTextFieldDelegate {
	var validateCancellable: AnyCancellable?
	var validateResultCancellable: AnyCancellable?
	var validateSubject = PassthroughSubject<String, Never>()
	var validateResultSubject = CurrentValueSubject<ValidateURLResult, Never>(.initial)
	@IBOutlet var prompt: NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()

		validateCancellable = validateSubject
			.map { url in
				if !self.validateResultSubject.value.isProcessing {
					self.validateResultSubject.send(.pending)
				}
				
				if url.isEmpty {
					self.validateResultSubject.send(.initial)
				}
				
				return url
			}
			.debounce(for: 1, scheduler: DispatchQueue.main)
			.flatMap { url in
				ApiHelper.validate(url: url)
			}
			.receive(on: DispatchQueue.main)
			.subscribe(validateResultSubject)
		
		validateResultCancellable = validateResultSubject.sink { (result) in
			self.prompt.stringValue = result.label
		}
	}

	func controlTextDidChange(_ obj: Notification) {
		guard let field = obj.object as? NSTextField else { return }
		print(field.stringValue)
		validateSubject.send(field.stringValue)
	}
}
