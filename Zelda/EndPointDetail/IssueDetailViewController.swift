//
//  IssueDetailViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/20.
//

import Cocoa

class IssueDetailViewController: NSViewController, EndPointDetailContainer {
	
	var loadable: EndPointDetailLoadable!
	var endPointId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if let destVC = segue.destinationController as? EndPointDetailLoadable {
			loadable = destVC
			loadable.setIndicator(.issue)
			loadable.endPointId = endPointId
		}
	}

}
