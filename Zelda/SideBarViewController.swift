//
//  SideBarViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/13.
//

import Cocoa

class SideBarViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	@IBOutlet weak var tableView: NSTableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
    }
    
	func numberOfRows(in tableView: NSTableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as! SideBarCell
		view.titleView.stringValue = "\(row)"
		return view
	}
}
