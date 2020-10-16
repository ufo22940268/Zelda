//
//  ScanLog.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation

typealias ObjectId = String

struct ScanLog: Identifiable {
	var id: ObjectId
	var url: String?
	var time: Date
	var duration: TimeInterval
	var errorCount: Int
	var endPointId: ObjectId
}

enum ScanLogSpan: String {
	case minutes
	case daily
	case weekly
}

typealias ScanLogInTimeSpan = [ScanLogSpan: [ScanLog]]
