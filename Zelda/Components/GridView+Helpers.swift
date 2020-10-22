//
//  GridView+Helpers.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/22.
//

import Cocoa

extension NSGridView {
	
	func removeRows() {
		(0 ..< self.numberOfRows).reversed().forEach { self.removeRow(at: $0) }
	}
}
