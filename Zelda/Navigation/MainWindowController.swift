//
//  MainWindow.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa
import Combine

class MainWindowController: NSWindowController {
	@IBOutlet var startRefreshButton: NSToolbarItem!
	var cancellables = Set<AnyCancellable>()

	var sideBarVC: AppViewController {
		contentViewController as! AppViewController
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		
		NotificationCenter.default.publisher(for: .refreshEnded)
			.sink { [weak self] (_) in
				self?.startRefreshButton.isEnabled = true
			}
			.store(in: &cancellables)
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "add", let vc = segue.destinationController as? EndPointEditViewController {
			vc.type = .edit
		}
	}

	@IBAction func onSelectSpan(_ button: NSPopUpButton) {
		let span = ScanLogSpan(id: button.selectedItem!.identifier!.rawValue)

		ConfigStore.shared.set(range: span)
		NotificationCenter.default.post(.init(name: .spanChanged))
	}

	@IBAction func onStartRefresh(_ sender: NSToolbarItem) {
		startRefreshButton.isEnabled = false
		NotificationCenter.default.post(.init(name: .startRefresh))
	}
}
