//
//  EndPointEntity+Helpers.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation


extension EndPointEntity {
	func toItem() -> EndPoint {
		///TODO Convert watch fields.
		EndPoint(url: self.url!, watchFields: [])
	}
}
