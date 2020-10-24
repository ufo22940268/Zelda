//
//  SidebarEmptyViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/24.
//

import Cocoa

protocol EmptyView {
	var label: String? { get set }
}

class SidebarEmptyViewController: NSViewController {
	var label: String? {
		didSet {
			if let label = label {
				labelView.stringValue = label
				rootView.isHidden = false
			} else {
				rootView.isHidden = true
			}
		}
	}
	
	@IBOutlet weak var labelView: NSTextField!
	@IBOutlet var rootView: NSView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
}

extension SidebarEmptyViewController: EmptyView {}
