//
//  SideBarContentViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Cocoa
import Combine

class SideBarContentViewController: NSViewController {
	var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		NotificationCenter.default.publisher(for: .syncEndPoint)
			.print()
			.sink { _ in
			}
			.store(in: &cancellables)
	}
}
