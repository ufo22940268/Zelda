//
//  EndPointInfoCellView.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/23.
//

import Cocoa

class EndPointInfoCellView: NSTableCellView {
	
	var row: Int! {
		didSet {
			infoButton.identifier = .init(String(row))
		}
	}
	
	@IBOutlet weak var infoButton: NSButton!
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
