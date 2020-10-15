//
//  ViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

class DisposableBag {
	// MARK: Lifecycle

	deinit {
		dispose()
	}

	// MARK: Internal

	var cancellables = Set<AnyCancellable>()

	func dispose() {
		cancellables.forEach { $0.cancel() }
	}
}

class ViewController: NSViewController {
	var disposableBag = DisposableBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
}
