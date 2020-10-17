//
//  ScanLog.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation

typealias ObjectId = String

let SCAN_LOG_COUNT = 7

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

	// MARK: Internal

	func indexes(last date: Date) -> [String] {
		switch self {
		case .minutes:
			let formatter = DateFormatter()
			formatter.dateFormat = .none
			formatter.timeStyle = .short
			return (0 ..< SCAN_LOG_COUNT).reversed().map { formatter.string(from: date - Double(60*5*$0)) }
		default:
			return []
		}
	}
}

typealias ScanLogInTimeSpan = [ScanLogSpan: [ScanLog]]
