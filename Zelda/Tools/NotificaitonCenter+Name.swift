//
//  NotificaitonCenter+Name.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/15.
//

import Foundation

extension NSNotification.Name {
	static let syncEndPoint = Self("syncEndPoint")
	static let deleteEndPoint = Self("deleteEndPoint")
	static let loadScanLog = Self("loadScanLog")
}
