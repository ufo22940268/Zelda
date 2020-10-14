//
//  MainWindow.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa

class MainWindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()

		// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "add", let vc = segue.destinationController as? EndPointEditViewController {
			vc.type = .edit
		}
	}
}
