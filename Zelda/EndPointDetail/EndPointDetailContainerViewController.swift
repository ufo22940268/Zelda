//
//  EndPointDetailContainerViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa

class EndPointDetailContainerViewController: NSViewController, EndPointLoadable {
	var tabVC: EndPointLoadable!

	func load(endPoint: String, url: String) {
		tabVC.load(endPoint: endPoint, url: url)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		tabVC = segue.destinationController as? EndPointLoadable
	}
	
	func onSelectSpan(_ span: ScanLogSpan) {
		
	}
}
